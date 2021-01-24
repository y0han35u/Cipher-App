<template>
    <h1>Caesar Cipher</h1>
    <textarea v-model="data.text" name="contents" id="contents" cols="30" rows="10" placeholder="Enter your text."></textarea>
    <div class="selector">
        <p>chose encryption key</p>
        
        <label for="rot-key">ROT:</label>
        <select v-model="data.rot_key" id="rot-key">
            <option value="" disabled>select the key.</option>
            <option v-for="n in 26" :key="n" value="n">{{ n }}</option>
        </select>
    </div>

    <form>
        <p>Encrypt or Decrypt?</p>

        <div>
            <input type="radio" v-model="ed_flag" id="enc" name="enc_dec" checked>
            <label for="enc">Encrypt</label>

            <input type="radio" v-model="ed_flag" id="dec" name="enc_dec">
            <label for="dec">Decrypt</label>
        </div>
    </form>

    <button>GO</button>
</template>

<script>
import { reactive } from 'vue'

export default {
    setup() {
        const data = reactive({
            text: '',
            rot_key: 0,
            ed_flag: '',
            text_list: [],
        })

        const CaesarCipher = ()=> {
            //script
        }

        const doAction = ()=> {
            //script
        }

        return { data, CaesarCipher, doAction }
    }
}
</script>