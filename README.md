# 🎯 UXIA - Panell d'Administració

Una aplicació per gestionar usuaris i administració de sistemes. Feta amb Flutter.

## Què és això?

És un programa que et deixa:
- ✅ Iniciar sessió com a admin
- ✅ Veure la llista d'usuaris
- ✅ Crear nous usuaris
- ✅ Canviar rols (admin/usuari normal)
- ✅ Eliminar usuaris
- ✅ Verificar si la teva sessió és vàlida

## 📋 Requisits

Abans de començar necessites:
- **Flutter** instal·lat (descarrega des de [flutter.dev](https://flutter.dev))
- **Node.js** instal·lat per al servidor
- **MySQL** executant-se
- Un editor de codi (VS Code, Android Studio, etc)

## 🚀 Com instal·lar

### 1. Clonar el projecte
```bash
git clone https://github.com/el-teu-usuari/UXIA_desktop
cd UXIA_desktop/uxia_desktop
```

### 2. Instal·lar dependències
```bash
flutter pub get
```

### 3. Executar l'aplicació
```bash
flutter run
```

Això és tot. L'aplicació s'obrirà a la teva pantalla.

## ⚙️ Configuració del Servidor

### Servidor Allotjat (Producció)

Normalment el servidor està allotjat a:
```
https://uxia3.ieti.site
```

En aquest cas, només cal que introdueixis aquesta URL a l'inici de sessió.

### Servidor Local (Desenvolupament)

Si vols executar el servidor localment:

```bash
cd UXIA_server
npm install
NODE_ENV=development node server.js
```

El servidor s'executarà en: `http://localhost:3000`

#### Base de Dades Local

Necessites MySQL corrent amb:
- **Host**: localhost
- **Port**: 3306  
- **Usuari**: uxia_user
- **Contrasenya**: password
- **Base de dades**: uxia_db

## � API del Servidor

El servidor UXIA ofereix diversos endpoints per gestionar usuaris i funcionalitats d'IA.

### Format de Resposta Estàndard

Totes les respostes de l'API segueixen aquest format:

```json
{
  "status": "OK",  // o "ERROR"
  "message": "Descripció de l'operació",
  "data": { ... }  // Dades addicionals (opcional)
}
```

### Autenticació

La majoria d'endpoints requereixen autenticació amb Bearer token:

```bash
Authorization: Bearer EL_TEU_TOKEN_AQUI
```

### Endpoints Principals

#### 🔐 Administradors

**Login d'Administrador**
```bash
POST /api/admin/usuaris/login
{
  "email": "admin@test.com",
  "password": "admin123"
}
```

**Llista d'Usuaris** (requereix token d'admin)
```bash
GET /api/admin/usuaris
Headers: Authorization: Bearer TOKEN_ADMIN
```

#### 👤 Usuaris

**Registre d'Usuari**
```bash
POST /api/usuaris/registrar
{
  "nickname": "ElMeuNickname",
  "email": "usuari@exemple.com",
  "telefon": "+34 600 000 000"
}
```

**Validació d'Usuari** (després de rebre SMS)
```bash
POST /api/usuaris/validar
{
  "telefon": "+34 600 000 000",
  "codi_validacio": 123456
}
```

**Obtenir Perfil** (requereix token)
```bash
GET /api/usuaris/perfil
Headers: Authorization: Bearer EL_TEU_TOKEN
```

#### 🤖 Intel·ligència Artificial

**Analitzar Imatge** (requereix token)
```bash
POST /api/analitzar-imatge
Headers: Authorization: Bearer EL_TEU_TOKEN
{
  "model": "qwen2.5vl:7b",
  "prompt": "Què hi ha en aquesta imatge?",
  "images": ["imatge_codificada_base64"],
  "stream": false
}
```

### Codis de Resposta HTTP Comuns

- **200 OK**: Tot correcte
- **201 Created**: Recurs creat amb èxit
- **400 Bad Request**: Dades invàlides
- **401 Unauthorized**: Token invàlid o absent
- **403 Forbidden**: No tens permisos
- **404 Not Found**: Recurs no trobat
- **500 Internal Server Error**: Error del servidor

## �👤 Usuari de Prova

Per provar l'aplicació amb el servidor de producció:
- **Email**: admin@test.com
- **Contrasenya**: admin123
- **URL**: uxia3.ieti.site

Si vols fer proves locals, usa `localhost:3000`

## 📱 Com Usar l'Aplicació

### Pantalla d'Inici de Sessió
1. Obrir l'aplicació
2. Prémer "Iniciar sessió"
3. Completa els camps:
   - URL del servidor (ex: localhost)
   - Nom d'usuari o email
   - Contrasenya
4. Prémer "Entrar"

### Menú Principal
Un cop dins veuràs 3 botons:
- **Gestionar Usuaris** - Anar a la llista d'usuaris
- **Informació Token** - Veure info de la teva sessió
- **Tancar Sessió** - Sortir de l'aplicació

### Gestionar Usuaris
Aquí pots:
- Veure tots els usuaris en una llista
- Crear nou usuari (botó + a baix)
- Canviar rol (botó blau d'editar)
- Eliminar usuari (botó vermell de paperera)

## 🔧 Estructura del Codi

```
lib/
├── main.dart              ← Punt de inici
├── constants/             ← Valors que no canvien
├── screens/               ← Les pantalles de l'aplicació
├── services/              ← Connexió amb el servidor
├── models/                ← Dades (usuari, etc)
├── widgets/               ← Components UI reutilitzables
└── utils/                 ← Funcions útils
```

## ❓ Problemes Comuns

### "No es pot connectar al servidor"
- Verifica que Node.js s'està executant
- Intenta amb `localhost:3000` manualment al navegador

### "Email invàlid"
- El correu ha de tenir format: quelcosa@exemple.com

### "Usuari no trobat"
- Si uses nickname, assegura't que existeix a la base de dades

### "Error de connexió"
- Verifica la teva connexió a internet
- Reinicia el servidor Node.js

## 📝 Notes

- L'aplicació guarda la teva URL i token localment
- El token expira si tanques sessió
- No pots canviar el teu propi rol d'admin
- Encara no hi ha contraseñes encriptades (és només per desenvolupament)

## 💡 Consells

- Usa `flutter analyze` per verificar que el codi està bé
- Usa `flutter run` en mode debug mentre desenvolupes
- Obrir DevTools amb `flutter pub global run devtools`

## 📞 Ajuda

Si quelcom no funciona:
1. Llegeix l'error amb cuidat
2. Busca a Google l'error
3. Verifica que totes les dependències estiguin instal·lades
4. Reinicia l'aplicació i el servidor

## ✨ Pròxim Pas

Un cop funciona tot, pots:
- Afegir més funcionalitats
- Canviar els colors i disseny
- Connectar amb més endpoints del servidor
- Fer proves i tests

---

## 👥 Equip de Desenvolupament

- **Victor P.**
- **Christopher C.**
- **Sabrina E.**

**Fet amb ❤️ per l'equip A.I.D.A**

