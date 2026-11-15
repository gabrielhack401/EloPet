# EloPet — reconstrução do zero

Projeto novo em branch isolada `elopet-reconstrucao-do-zero`.

- `web/`: site HTML/JavaScript.
- `lib/`: app Flutter Android.
- Firestore, Authentication e Storage compartilhados pelos dois clientes.

## Configuração
1. Configure o app Web no Firebase e preencha `web/firebase-config.js`.
2. Ative login por e-mail/senha e Google no Firebase Authentication.
3. Configure FlutterFire: `flutterfire configure --project=inovar-para-acolher`.
4. Publique regras: `firebase deploy --only firestore:rules,storage`.
5. Publique site: `firebase deploy --only hosting`.

O primeiro administrador deve ser promovido manualmente no Firebase Console em `users/{uid}` (`role: admin`). Não existe opção de autoelevação no cliente.

Esta branch é uma base nova. O deploy não foi executado e o Firebase ainda exige configuração de credenciais.