package io.github.ccch1mneyyy.dsh_app.vault

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * 密钥保险箱：把一段秘密（比如 age 私钥）用 Android Keystore 里的 AES 密钥包起来。
 *
 * - 密钥绑系统锁屏：`setUserAuthenticationRequired(true)`，使用前必须过系统确认
 *   （指纹 / 锁屏密码都行），确认后 30 秒内可用。
 * - 录入和解锁都走系统确认界面，App 自己不画密码框。
 * - 密文存在 SharedPreferences；Keystore 里的密钥不可导出，root 之外拿不到明文。
 */
class VaultPlugin(
    private val activity: Activity,
    messenger: io.flutter.plugin.common.BinaryMessenger,
) : MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {

    private val channel = MethodChannel(messenger, "dsh/vault")
    private val prefs = activity.getSharedPreferences("dsh_vault", Context.MODE_PRIVATE)

    private var pendingResult: MethodChannel.Result? = null
    private var pendingSecret: ByteArray? = null
    private var pendingOp: String? = null

    fun attach() {
        channel.setMethodCallHandler(this)
    }

    fun detach() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> result.success(prefs.contains(ALIAS))
            "enroll" -> {
                val secret = call.argument<String>("secret")
                if (secret.isNullOrEmpty()) {
                    result.error("bad_args", "secret missing", null)
                    return
                }
                start("enroll", secret.toByteArray(Charsets.UTF_8), result)
            }
            "unlock" -> start("unlock", null, result)
            "security" -> result.success(security())
            "secure" -> {
                val on = call.argument<Boolean>("on") ?: true
                activity.runOnUiThread {
                    if (on) activity.window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                    else activity.window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(true)
            }
            "clear" -> {
                runCatching {
                    keyStore().deleteEntry(ALIAS)
                    prefs.edit().clear().apply()
                }
                result.success(true)
            }
            "writeKeyTo" -> {
                // 调试/迁移用：把已解锁的私钥写到 app 目录下，不做长期存储。
                result.error("unsupported", "not implemented", null)
            }
            else -> result.notImplemented()
        }
    }

    private fun start(op: String, secret: ByteArray?, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "another vault request is running", null)
            return
        }
        val km = activity.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || !km.isDeviceSecure) {
            result.error("no_lock", "设备没有设置锁屏，无法绑定密钥", null)
            return
        }
        val intent = km.createConfirmDeviceCredentialIntent("解锁密钥保险箱", "用指纹或锁屏密码确认")
        if (intent == null) {
            result.error("no_prompt", "系统没有可用的确认方式", null)
            return
        }
        pendingResult = result
        pendingOp = op
        pendingSecret = secret
        activity.startActivityForResult(intent, REQ)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQ) return false
        val result = pendingResult ?: return true
        pendingResult = null
        val op = pendingOp
        pendingOp = null
        val secret = pendingSecret
        pendingSecret = null
        if (resultCode != Activity.RESULT_OK) {
            result.error("cancelled", "user cancelled", null)
            return true
        }
        runCatching {
            when (op) {
                "enroll" -> enroll(secret!!)
                "unlock" -> unlock()
                else -> error("unknown op")
            }
        }.onSuccess { result.success(it) }
            .onFailure { result.error("vault_error", it.message ?: "vault failed", null) }
        return true
    }

    /** 当前环境的事实：调试版、密钥是否在安全硬件里、是否要求设备已解锁。 */
    private fun security(): Map<String, Any> {
        val debuggable = (activity.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
        var hardwareBacked = false
        runCatching {
            val key = secretKey(create = false) ?: return@runCatching
            val factory = javax.crypto.SecretKeyFactory.getInstance(key.algorithm, "AndroidKeyStore")
            val info = factory.getKeySpec(key, android.security.keystore.KeyInfo::class.java)
                    as android.security.keystore.KeyInfo
            hardwareBacked = info.isInsideSecureHardware
        }
        return mapOf(
            "debuggable" to debuggable,
            "hardwareBacked" to hardwareBacked,
            "unlockedDeviceRequired" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P),
            "biometricInvalidation" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N),
        )
    }

    private fun keyStore(): KeyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    private fun secretKey(create: Boolean): SecretKey? {
        val ks = keyStore()
        if (!ks.containsAlias(ALIAS)) {
            if (!create) return null
            val gen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
            val spec = KeyGenParameterSpec.Builder(
                ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setUserAuthenticationRequired(true)
                .apply {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        setUserAuthenticationParameters(AUTH_WINDOW, KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL)
                    } else {
                        @Suppress("DEPRECATION")
                        setUserAuthenticationValidityDurationSeconds(AUTH_WINDOW)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        setInvalidatedByBiometricEnrollment(true)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        setUnlockedDeviceRequired(true)
                    }
                }
                .build()
            gen.init(spec)
            return gen.generateKey()
        }
        return (ks.getEntry(ALIAS, null) as? KeyStore.SecretKeyEntry)?.secretKey
    }

    private fun enroll(secret: ByteArray): Boolean {
        val key = secretKey(create = true) ?: error("keystore 里建不出密钥")
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val blob = cipher.doFinal(secret)
        val b64 = Base64.encodeToString(blob, Base64.NO_WRAP)
        val iv = Base64.encodeToString(cipher.iv, Base64.NO_WRAP)
        prefs.edit().putString(ALIAS, "$iv:$b64").apply()
        secret.fill(0)
        return true
    }

    private fun unlock(): String {
        val stored = prefs.getString(ALIAS, null) ?: error("还没有录入密钥")
        val key = secretKey(create = false) ?: error("keystore 里没有密钥")
        val (ivB64, bodyB64) = stored.split(':', limit = 2)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(
            Cipher.DECRYPT_MODE,
            key,
            GCMParameterSpec(128, Base64.decode(ivB64, Base64.NO_WRAP)),
        )
        val plain = cipher.doFinal(Base64.decode(bodyB64, Base64.NO_WRAP))
        val text = String(plain, Charsets.UTF_8)
        plain.fill(0)
        return text
    }

    companion object {
        private const val ALIAS = "dsh-vault-key"
        private const val REQ = 0x5601
        private const val AUTH_WINDOW = 30
    }
}
