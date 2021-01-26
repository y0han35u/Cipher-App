<template>
    <div class="header">
        <button @click="doLogin">{{ data.status_msg }}</button>
        <p v-if="data.user">Hello! {{ data.user }}</p>
    </div>
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

    <div class="list" v-if="data.user">
        <ul>
          <li v-for="(item, key) in data.fire_data" :key="key">{{ item.text }}</li> 
        </ul>
    </div>
id
    <div class="list2" v-if="data.user == null">
        <ul>
            <li v-for="item in data.obj_list" :key="item.key">{{ item.text }}</li>
        </ul>
    </div>
</template>

<script>
import { reactive } from 'vue'
import firebase from 'firebase'

// Your web app's Firebase configuration
var firebaseConfig = {
   apiKey: "AIzaSyCUhuV-5NE699PnLQ4akulxUsa-giMM0VY",
   authDomain: "cipher-app-71877.firebaseapp.com",
   projectId: "cipher-app-71877",
   storageBucket: "cipher-app-71877.appspot.com",
   messagingSenderId: "628117390597",
   appId: "1:628117390597:web:d9ec107576e3b5bdbc636c"
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);

var provider = new firebase.auth.GoogleAuthProvider()
//const fdata = firebase.database().ref('data/')


export default {
    setup() {
        const data = reactive({
            text: '',
            rot_key: 0,
            ed_flag: '',
            obj_list: [],
            status_msg: 'Login',
            user: null,
            fire_data: {},
        })

        const CaesarCipher = (str, rot, x)=> {
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

        const getCreateTimeId = ()=> {
            let d = new Date()
            let dstr = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate() + ' ' + d.getHours() + ':' + d.getMinutes() + ':' + d.getSeconds()
            let id = d.getTime()
            return {time: dstr, id: id}
        }

        const doAction = (text, rot_key, ed_flag)=> {
            console.log(text, rot_key, ed_flag)
            let user = firebase.auth().currentUser
            let timeId = getCreateTimeId()
            let id = timeId.id
            let obj = {
                text: CaesarCipher(text, rot_key, ed_flag),
                user: user.displayName,
                posted: timeId.time,
                cryptType: 'CaesarCipher',
            }
            if(data.user != null){
                firebase.database().ref('data/' + id).set(obj)
                data.obj_list = []
            } else {
                let lcl_obj = {
                    text: CaesarCipher(text, rot_key, ed_flag),
                    id: id,
                    posted: timeId.time,
                    cryptType: 'CaesarCipher',
                }
                data.obj_list.unshift(lcl_obj)
            }
            
        }

        const login = ()=> {
            firebase.auth().signInWithPopup(provider).then((result)=> {
                data.user = result.user
                if (data.obj_list.length) {
                    for(let item in data.obj_list){
                        let id = item.id
                        let obj = {
                            text: item.text,
                            user: firebase.auth().currentUser.displayName,
                            posted: item.time,
                            cryptType: 'CaesarCipher',
                        }
                        firebase.database().ref('data/' + id).set(obj)
                    }
                    data.obj_list = []
                }
                firebase.database().ref('data').once('value', (snapshot)=>{
                    if (firebase.auth().currentUser != null) {
                        console.log(snapshot)
                        let arr = []
                        let result = snapshot.val()
                        console.log(result)
                        for(let item in result){
                            arr.unshift(result[item])
                        }
                        console.log(arr)
                        data.fire_data = arr
                        data.status_msg = 'Logout'
                    } else {
                        data.fire_data = {}
                    }
                })
            })
        }

        const logout = ()=> {
            firebase.auth().signOut()
            data.user = null
            data.status_msg = 'Login'
            data.obj_list = []
        }

        const doLogin = ()=> {
            if(firebase.auth().currentUser == null){
                login()
            } else {
                logout()
            }
        }

        return { data, CaesarCipher, doAction, login, logout, doLogin, getCreateTimeId }
    }
}
</script>