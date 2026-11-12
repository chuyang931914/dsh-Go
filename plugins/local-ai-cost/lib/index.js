// AI cost: DeepSeek balance now; Volcengine billing once AK/SK is wired.
// Runs inside the DSH engine (Node). Never puts credentials into a view.
import { readFileSync, statSync } from 'node:fs'
import { billing } from '@volcengine/openapi'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

export const name = 'local-ai-cost'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))
const SECRETS = join(ROOT, 'secrets.json')
const REFRESH_MS = 30 * 60 * 1000

let lastUpdated = null
let deepseek = null // { value, caption, tone }
let volcano = null // { value, caption, tone }
let stripEmitter = null
let panelEmitter = null
let seed = null
let timer = null
let busy = false
let lastError = ''

function readSecrets() {
  try {
    const mode = statSync(SECRETS).mode & 0o777
    if (mode & 0o077) lastError = 'secrets.json 权限过宽，建议 chmod 600'
    return JSON.parse(readFileSync(SECRETS, 'utf8'))
  } catch {
    return {}
  }
}

function money(value, currency) {
  const n = Number(value)
  if (!Number.isFinite(n)) return `—`
  return `${currency === 'CNY' ? '¥' : `${currency || ''} `}${n.toFixed(2)}`.trim()
}

function clock() {
  return new Date().toLocaleTimeString('zh-CN', { hour12: false, hour: '2-digit', minute: '2-digit' })
}

async function fetchDeepseek(apiKey) {
  if (!apiKey) return { value: '未配置', caption: 'secrets.json · deepseek.apiKey', tone: 'warn' }
  try {
    const res = await fetch('https://api.deepseek.com/user/balance', {
      headers: { Authorization: `Bearer ${apiKey}`, Accept: 'application/json' },
      signal: AbortSignal.timeout(15_000),
    })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    const body = await res.json()
    const infos = Array.isArray(body.balance_infos) ? body.balance_infos : []
    const info = infos.find((x) => x.currency === 'CNY') ?? infos[0]
    if (!info) throw new Error('no balance info')
    return {
      value: money(info.total_balance, info.currency),
      caption: `可用 ${body.is_available === false ? '否' : '是'} · ${clock()}`,
      tone: body.is_available === false ? 'warn' : 'good',
    }
  } catch (error) {
    lastError = error instanceof Error ? error.message : String(error)
    return {
      value: deepseek?.value ?? '读取失败',
      caption: `上次成功 ${lastUpdated?.clock ?? '—'} · 刚刚失败`,
      tone: 'warn',
    }
  }
}

function period() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

async function fetchVolc(secrets) {
  const v = secrets.volcengine ?? {}
  if (!v.accessKeyId || !v.secretAccessKey) {
    return { value: '未配置', caption: 'secrets.json · volcengine AK/SK', tone: 'warn' }
  }
  try {
    const svc = billing.defaultService
    svc.setAccessKeyId(v.accessKeyId)
    svc.setSecretKey(v.secretAccessKey)
    svc.setRegion(v.region || 'cn-north-1')
    const month = period()
    const data = { BillPeriod: month, Limit: '100', Offset: '0', IgnoreZero: '1' }
    const res = await svc.ListBillOverviewByProd(data, { query: data })
    if (res?.ResponseMetadata?.Error) throw new Error(res.ResponseMetadata.Error.Message)
    const list = res?.Result?.List ?? []
    const total = list.reduce((sum, item) => sum + Number(item.PayableAmount || 0), 0)
    const names = [...new Set(list.map((item) => item.ProductZh || item.Product).filter(Boolean))]
    return {
      value: `¥${total.toFixed(2)}`,
      caption: list.length ? `${month} · ${names.slice(0, 2).join('、')}${names.length > 2 ? ' 等' : ''}` : `${month} · 暂无账单`,
      tone: 'good',
    }
  } catch (error) {
    lastError = error instanceof Error ? error.message : String(error)
    return {
      value: volcano?.value ?? '读取失败',
      caption: `上次成功 ${lastUpdated?.clock ?? '—'} · 刚刚失败`,
      tone: 'warn',
    }
  }
}

async function refreshAll(force = false) {
  if (busy && !force) return
  busy = true
  lastError = ''
  const secrets = readSecrets()
  const [d, v] = await Promise.all([
    fetchDeepseek(secrets.deepseek?.apiKey),
    fetchVolc(secrets),
  ])
  deepseek = d
  volcano = v
  lastUpdated = { clock: clock(), at: Date.now() }
  busy = false
  emit()
}

function emit() {
  const d = deepseek ?? { value: '未读取', caption: '正在读取…', tone: 'warn' }
  const v = volcano ?? { value: '未读取', caption: '正在读取…', tone: 'warn' }
  const both = v.value !== '未配置' && v.value !== '读取失败'
  stripEmitter?.({ text: (both ? `火山 ${v.value} · DS ${d.value}` : `DeepSeek ${d.value}`).slice(0, 24), icon: 'wallet', tone: d.tone })
  panelEmitter?.({
    deepseek: d.value,
    deepseekCaption: d.caption,
    deepseekTone: d.tone,
    volcano: v.value,
    volcanoCaption: v.caption,
    volcanoTone: v.tone,
    updated: lastUpdated ? `更新 ${lastUpdated.clock}${lastError ? ' · 有错误' : ''}` : '尚未更新',
  })
}

function ensureTimer() {
  if (timer) return
  timer = setInterval(() => void refreshAll(), REFRESH_MS)
  timer.unref?.()
}

export function apply(ctx) {
  ctx.inject(['dshGo'], (ctx) => {
    ctx.dshGo.strip('cost-line', (scope, emitStrip) => {
      stripEmitter = emitStrip
      ensureTimer()
      void refreshAll()
      return () => { stripEmitter = null }
    })

    ctx.dshGo.panel('cost', {
      view: (scope, caps) => {
        const zh = !String(caps.locale).startsWith('en')
        return {
          type: 'stack',
          children: [
            { type: 'metric', label: 'DeepSeek', value: { $: 'data.deepseek' }, caption: { $: 'data.deepseekCaption' }, tone: { $: 'data.deepseekTone' } },
            { type: 'metric', label: zh ? '火山本月' : 'Volcengine this month', value: { $: 'data.volcano' }, caption: { $: 'data.volcanoCaption' }, tone: { $: 'data.volcanoTone' } },
            { type: 'text', text: { $: 'data.updated' }, tone: 'muted' },
            { type: 'actions', items: [{ label: zh ? '刷新' : 'Refresh', action: 'refresh', icon: 'refresh' }] },
          ],
        }
      },
      data: (scope, emitData) => {
        panelEmitter = emitData
        ensureTimer()
        void refreshAll()
        return () => { panelEmitter = null }
      },
      actions: {
        refresh: () => {
          void refreshAll(true)
          return { toast: '正在刷新' }
        },
      },
    })
  })
}
