package com.bug.build_growth_mobile
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Handler
import android.os.Looper
import com.github.devnied.emvnfccard.parser.EmvTemplate
import com.github.devnied.emvnfccard.model.enums.CardStateEnum
import java.io.IOException
import java.text.SimpleDateFormat

class NfcScanner(private val plugin: EmvCardReaderPlugin) : NfcAdapter.ReaderCallback {
    private val handler = Handler(Looper.getMainLooper())

    override fun onTagDiscovered(tag: Tag) {
        val sink = plugin.sink ?: return

        var id: IsoDep

        try {
            id = IsoDep.get(tag)
            id.connect()
        } catch (e: IOException) {
            handler.post{ sink.success(null) }

            return
        }catch (e: Exception) {
            val invalid = HashMap<String, String?>()
            invalid.put("type", "Invalid")
            invalid.put("number", "-")
            invalid.put("expire", "-")
            invalid.put("holder", "-")
            invalid.put("status", "Not a Visa/ Master Card")

            handler.post{ sink.success(invalid) }
            return
        }

        val provider = IsoDepProvider(id)
        val config = EmvTemplate.Config()

        val parser = EmvTemplate.Builder().setProvider(provider).setConfig(config).build()

        val card = parser.readEmvCard()

        var number: String? = null
        var expire: String? = null
        var holder: String? = null
        var type: String? = null
        var status: String? = null

        val fmt = SimpleDateFormat("MM/YY")

        if (card.track1 != null) {
            number = card.track1.cardNumber
            expire = fmt.format(card.track1.expireDate)
        } else if (card.track2 != null) {
            number = card.track2.cardNumber
            expire = fmt.format(card.track2.expireDate)
        }

        if (card.holderFirstname != null && card.holderLastname != null) {
            holder = card.holderFirstname + " " + card.holderLastname
        }

        if (card.type != null) {
            type = card.type.name
        }else if (card.applications.isNotEmpty()) {
            type = card.applications[0].applicationLabel
        }

        if (card.state == CardStateEnum.UNKNOWN) {
            status = "unknown"
        } else if (card.state == CardStateEnum.LOCKED) {
            status = "locked"
        } else if (card.state == CardStateEnum.ACTIVE) {
            status = "active"
        }
        
       
        val res = HashMap<String, String?>()
        res.put("type", type)
        res.put("number", number)
        res.put("expire", expire)
        res.put("holder", holder)
        res.put("status", status)

        handler.post{ sink.success(res) }

        id.close()
    }
}
