<template>
    <h1>Caesar Cipher</h1>
    <textarea v-model="data.text" name="contents" id="contents" cols="30" rows="10" placeholder="Enter your text."></textarea>
    <div class="selector">
        <p>chose encryption key</p>
        
        <label for="rot-key">ROT:</label>
        <select v-model="data.rot_key" id="rot-key">
            <option v-for="n in 26" :key="n">{{ n }}</option>
        </select>
    </div>

    <form>
        <p>Encrypt or Decrypt?</p>

        <div>
            <input type="radio" id="enc" name="enc_dec" value="Encrypt" v-model="data.ed_flag">
            <label for="enc">Encrypt</label>

            <input type="radio" id="dec" name="enc_dec" value="Decrypt" v-model="data.ed_flag">
            <label for="dec">Decrypt</label>
        </div>
    </form>

    <button @click="doAction(data.text, data.rot_key, data.ed_flag)">GO</button>

    <div>
        <ul>
          <li v-for="(item, index) in data.text_list" :key="index">{{ item }}</li> 
        </ul>
    </div>
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

        const CaesarCipher = (str, rot, x)=> {
            console.log(str, rot, x)
            var lowerStr = str.toLowerCase();
            var alphabet = "abcdefghijklmnopqrstuvwxyz".split("");
            var result = "";

            for (let i = 0; i < lowerStr.length; i++) {
                var letter = lowerStr[i];
                var pattern = /[a-z]/;

                if (pattern.test(letter) === false) {
                result += letter;
                continue;
                }

                var currentIndex = alphabet.indexOf(letter);
                var newIndex;
                
                if (x === "Encrypt") {
                newIndex = parseInt(currentIndex) + parseInt(rot);
                } else {
                newIndex = currentIndex - rot;
                }
                
                if (newIndex > 25) newIndex = newIndex - 26;
                if (newIndex < 0) newIndex = newIndex + 26;

                if (str[i] === str[i].toUpperCase()) {
                result += alphabet[newIndex].toUpperCase();
                } else {
                result += alphabet[newIndex];
                }
            }
            return result;
        }

        const doAction = (text, rot_key, ed_flag)=> {
            console.log(text, rot_key, ed_flag)
            data.text_list.unshift(CaesarCipher(text, rot_key, ed_flag));
        }

        return { data, CaesarCipher, doAction }
    }
}
</script>