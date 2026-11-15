import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
 await GoogleSignIn.instance.initialize();
 runApp(const EloPetApp());
}
class EloPetApp extends StatelessWidget {
 const EloPetApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'EloPet',debugShowCheckedModeBanner:false,theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF176B55)),useMaterial3:true),home:const AuthGate());
}
class AuthGate extends StatelessWidget {
 const AuthGate({super.key});
 @override Widget build(BuildContext context)=>StreamBuilder<User?>(stream:FirebaseAuth.instance.authStateChanges(),builder:(context,s){if(s.connectionState==ConnectionState.waiting)return const Scaffold(body:Center(child:CircularProgressIndicator()));return s.data==null?const LoginPage():const HomePage();});
}
class LoginPage extends StatefulWidget {const LoginPage({super.key});@override State<LoginPage> createState()=>_LoginPageState();}
class _LoginPageState extends State<LoginPage>{
 final email=TextEditingController(),password=TextEditingController();bool busy=false;String error='';
 Future<void> login({bool create=false})async{setState(()=>busy=true);try{final a=FirebaseAuth.instance;UserCredential c;if(create){c=await a.createUserWithEmailAndPassword(email:email.text.trim(),password:password.text);await FirebaseFirestore.instance.collection('users').doc(c.user!.uid).set({'uid':c.user!.uid,'email':c.user!.email,'role':'user','createdAt':FieldValue.serverTimestamp()});}else{await a.signInWithEmailAndPassword(email:email.text.trim(),password:password.text);}}catch(e){setState(()=>error=e.toString());}finally{if(mounted)setState(()=>busy=false);}}
 Future<void> google()async{setState(()=>busy=true);try{final account=await GoogleSignIn.instance.authenticate();final credential=GoogleAuthProvider.credential(idToken:account.authentication.idToken);final result=await FirebaseAuth.instance.signInWithCredential(credential);final u=result.user!;await FirebaseFirestore.instance.collection('users').doc(u.uid).set({'uid':u.uid,'email':u.email,'name':u.displayName,'photoUrl':u.photoURL,'role':'user'},SetOptions(merge:true));}catch(e){setState(()=>error=e.toString());}finally{if(mounted)setState(()=>busy=false);}}
 @override Widget build(BuildContext context)=>Scaffold(body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:420),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Icon(Icons.pets,size:64,color:Color(0xFF176B55)),const Text('EloPet',textAlign:TextAlign.center,style:TextStyle(fontSize:34,fontWeight:FontWeight.bold)),TextField(controller:email,decoration:const InputDecoration(labelText:'E-mail')),TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Senha')),if(error.isNotEmpty)Text(error,style:const TextStyle(color:Colors.red)),FilledButton(onPressed:busy?null:()=>login(),child:const Text('Entrar')),OutlinedButton(onPressed:busy?null:()=>login(create:true),child:const Text('Criar conta')),OutlinedButton(onPressed:busy?null:google,child:const Text('Continuar com Google'))])))));
 }
}
class HomePage extends StatefulWidget {const HomePage({super.key});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
 final name=TextEditingController(),species=TextEditingController(),city=TextEditingController(),description=TextEditingController();bool busy=false;
 Future<void> addAnimal()async{final u=FirebaseAuth.instance.currentUser!;if(name.text.trim().isEmpty||species.text.trim().isEmpty)return;setState(()=>busy=true);try{await FirebaseFirestore.instance.collection('animals').add({'name':name.text.trim(),'species':species.text.trim(),'city':city.text.trim(),'description':description.text.trim(),'ownerId':u.uid,'status':'pending','createdAt':FieldValue.serverTimestamp()});name.clear();species.clear();city.clear();description.clear();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Animal enviado para aprovação.')));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}finally{if(mounted)setState(()=>busy=false);}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('EloPet 🐾'),actions:[IconButton(onPressed:()=>FirebaseAuth.instance.signOut(),icon:const Icon(Icons.logout))]),body:ListView(padding:const EdgeInsets.all(16),children:[Text('Olá, '+(FirebaseAuth.instance.currentUser?.email??'protetor'),style:Theme.of(context).textTheme.headlineSmall),const Text('Site e aplicativo usam as mesmas coleções Firebase.'),const SizedBox(height:18),Text('Cadastrar animal',style:Theme.of(context).textTheme.titleLarge),TextField(controller:name,decoration:const InputDecoration(labelText:'Nome')),TextField(controller:species,decoration:const InputDecoration(labelText:'Espécie')),TextField(controller:city,decoration:const InputDecoration(labelText:'Cidade')),TextField(controller:description,decoration:const InputDecoration(labelText:'Descrição')),FilledButton(onPressed:busy?null:addAnimal,child:const Text('Enviar para aprovação')),const SizedBox(height:24),Text('Animais aprovados',style:Theme.of(context).textTheme.titleLarge),StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('animals').where('status',isEqualTo:'approved').snapshots(),builder:(context,s){if(s.hasError)return Text('Erro: '+s.error.toString());if(!s.hasData)return const CircularProgressIndicator();if(s.data!.docs.isEmpty)return const Text('Ainda não há animais aprovados.');return Column(children:s.data!.docs.map((d)=>ListTile(leading:const Icon(Icons.pets),title:Text(d.data()['name']??'Animal'),subtitle:Text((d.data()['species']??'')+' · '+(d.data()['city']??''))).toList());})]));
 }
}
