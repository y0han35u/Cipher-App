<template>
    <header> 
        <p v-if="data.user">Hello! {{ data.user.displayName }}</p>
	<p v-else>Hi! there!</p>
        <button @click="doLogin">{{ data.status_msg }}</button>
    </header>
    
    <main>
    <section>
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
    </section>
    
    <div class="list" v-if="data.user">
        <ul>
          <li v-for="(item, key) in data.fire_data" :key="key">{{ item.text }}</li> 
        </ul>
    </div>



    <div class="list2" v-if="data.user == null">
        <ul>
            <li v-for="item in data.obj_list" :key="item.id">{{ item.text }}</li>
        </ul>
    </div>
    </main>
</template>

<script>
import { reactive } from 'vue'
import firebase from 'firebase'

// Your web app's Firebase configuration
var firebaseConfig = {
   apiKey:  process.env.VUE_APP_FIREBASE_API_KEY,
   authDomain: process.env.VUE_APP_FIREBASE_AUTH_DOMAIN,
   projectId: process.env.VUE_APP_FIREBASE_PROJECT_ID,
   storageBucket: process.env.VUE_APP_FIREBASE_STORAGE_BUCKET,
   messagingSenderId: process.env.VUE_APP_FIREBASE_MESSAGING_SENDER_ID,
   appId: process.env.VUE_APP_APP_ID 
};
console.log(process.env.VUE_APP_FIREBASE_API_KEY)
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
            let obj = {time: dstr, id: id}
            console.log('GCTI' + JSON.stringify(obj))
            return obj
        }

        const doAction = (text, rot_key, ed_flag)=> {
            console.log(text, rot_key, ed_flag)
            let timeId = getCreateTimeId()
            let id = timeId.id
            
            if(data.user != null){
                let user = firebase.auth().currentUser
                let obj = {
                    text: CaesarCipher(text, rot_key, ed_flag),
                    user: user.displayName,
                    posted: timeId.time,
                    cryptType: 'CaesarCipher',
                }
                firebase.database().ref('data/' + id).set(obj)
                console.log('doAction firebase' + JSON.stringify(obj))
            } else {
                let lcl_obj = {
                    text: CaesarCipher(text, rot_key, ed_flag),
                    id: id,
                    posted: timeId.time,
                    cryptType: 'CaesarCipher',
                }
                data.obj_list.unshift(lcl_obj)
                console.log('doAction local' + JSON.stringify(lcl_obj))
                console.log('data.obj_list' + data.obj_list)
            }
            
        }

        const login = ()=> {
            firebase.auth().signInWithPopup(provider).then((result)=> {
                data.user = result.user
                console.log('login' + data.user.displayName)
                if (data.obj_list.length) {
                    data.obj_list.forEach(item => {
                        console.log(' item ' + JSON.stringify(item))
                        let id = item.id
                        let obj = {
                            text: item.text,
                            user: firebase.auth().currentUser.displayName,
                            posted: item.posted,
                            cryptType: 'CaesarCipher',
                        }
                        firebase.database().ref('data/' + id).set(obj)
                        console.log('push item ' + JSON.stringify(item))
                    });
                    data.obj_list = []
                    console.log('Login and push local obj')
                }
                firebase.database().ref('data').orderByChild('user').equalTo(firebase.auth().currentUser.displayName).on('value', (snapshot)=>{
                    if (firebase.auth().currentUser != null) {
                        console.log('get snap'+snapshot)
                        let arr = []
                        let result = snapshot.val()
                        console.log('get result' + result)
                        for(let item in result){
                            arr.unshift(result[item])
                        }
                        console.log('get arr' + arr)
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
            console.log('logout')
        }

        const doLogin = ()=> {
            if(firebase.auth().currentUser == null){
                console.log(firebase.auth().currentUser)
                login()
            } else {
                logout()
            }
        }

        return { data, CaesarCipher, doAction, login, logout, doLogin, getCreateTimeId }
    }
}
</script>

<style>
header {
	background-color: orange;
	display: flex;
	width: 100%;
	height: 100px;
	align-items: center;
}	

header p { 
	margin-right: auto;
	font-size: 25px;
	padding: 10px;
}

header button { 
	margin-right: 20px;
	padding: 10px;
	background-color: skyblue;
	color: white;
}

main { 
	background-color: black;
	color: white;
	padding-bottom: 100%;
	font-size: 20px;
}

section > h1 { 
	font-size: 50px;
	padding-top: 25px;
}

section > button {
	margin-top: 10px;
}
</style>
