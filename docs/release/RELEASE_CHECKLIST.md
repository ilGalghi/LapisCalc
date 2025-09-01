# 🚀 Checklist per il Rilascio su Google Play Store

Questa checklist ti guiderà attraverso tutti i passaggi necessari per rilasciare un aggiornamento di LapisCalc su Google Play Store.

## 📋 Pre-Release Checklist

### 1. **Aggiornamento Versioni** 📝

#### A. Versione App (pubspec.yaml)
```yaml
# In pubspec.yaml, riga 7
version: 1.1.9  # Incrementa la versione (es: 1.1.7 → 1.1.8)
```

#### B. Version Code (build.gradle)
```gradle
// In android/app/build.gradle, riga 18
flutterVersionCode = '7'  // Incrementa il version code (es: 6 → 7)
```

#### C. Settings page (\lib\pages\settings_page.dart)
```gradle
const ListTile(
    leading: Icon(Icons.info_outline),
    title: Text("App Version"),
    subtitle: Text("1.1.7"),          //da modificare ogni release
    ),
    ListTile(
    leading: const Icon(Icons.info_outline),
    title: const Text("Licenses"),
    onTap: () => showLicensePage(
        context: context,
        applicationName: "LapisCalc",
        applicationVersion: "1.1.7"),     //da modificare ogni release
    ),
```

**Regole per il versioning:**
- **Version Name** (pubspec.yaml): Formato semantico (es: 1.1.8)
- **Version Code** (build.gradle): Numero intero che deve essere sempre maggiore del precedente

### 2. **Test dell'App** 🧪

- [ ] Testa l'app in modalità debug
- [ ] Testa l'app in modalità release
- [ ] Verifica che tutte le funzionalità principali funzionino
- [ ] Controlla le traduzioni in tutte le lingue supportate
- [ ] Testa su diversi dispositivi Android (se possibile)

### 3. **Preparazione Build** 🔨

```bash
# Pulisci la cache
flutter clean

# Reinstalla le dipendenze
flutter pub get

# Genera le localizzazioni
flutter gen-l10n

# Testa il build
flutter build appbundle
```

### 4. **Documentazione Changelog** 📝

Crea un nuovo file changelog in `metadata/en-US/changelogs/`:

**Nome file:** `118.txt` (incrementa il numero)

**Contenuto esempio:**
```
In pubspec.yaml:
- Update version to 1.1.8

In build.gradle:
- Update versionCode to 7

Play Store:
News:
- Bug fixes and performance improvements
- New features added

-------------------------------------------------------

<en-US>
News:
- Bug fixes and performance improvements
- New features added
</en-US>
<es-ES>
Novedades:
- Corrección de errores y mejoras de rendimiento
- Nuevas funciones añadidas
</es-ES>
<fr-FR>
Nouveautés :
- Correction de bugs et améliorations des performances
- Nouvelles fonctionnalités ajoutées
</fr-FR>
<it-IT>
Novità:
- Correzione di bug e miglioramenti delle prestazioni
- Nuove funzionalità aggiunte
</it-IT>
<ro>
Noutăți:
- Remediere a erorilor și îmbunătățiri ale performanței
- Funcții noi adăugate
</ro>
```

### 5. **Build Finale** 🏗️

```bash
# Build dell'app bundle per il rilascio
flutter build appbundle --release
```

Il file AAB sarà creato in: `build/app/outputs/bundle/release/app-release.aab`

## 📱 Google Play Console

### 1. **Accesso alla Console**
- Vai su [Google Play Console](https://play.google.com/console)
- Accedi con il tuo account sviluppatore

### 2. **Seleziona l'App**
- Clicca su "LapisCalc" dalla lista delle tue app

### 3. **Crea Nuovo Rilascio**
- Vai su "Produzione" → "Gestisci" → "Crea nuovo rilascio"
- Oppure "Test interno" → "Crea nuovo rilascio" (per test)

### 4. **Carica il File AAB**
- Trascina il file `app-release.aab` nella sezione "App bundle"
- Aspetta che il caricamento sia completato

### 5. **Compila le Informazioni di Rilascio**

#### A. **Note di Rilascio**
Copia le note dal file changelog appena creato per ogni lingua:

**Inglese (en-US):**
```
News:
- Bug fixes and performance improvements
- New features added
```

**Spagnolo (es-ES):**
```
Novedades:
- Corrección de errores y mejoras de rendimiento
- Nuevas funciones añadidas
```

**Francese (fr-FR):**
```
Nouveautés :
- Correction de bugs et améliorations des performances
- Nouvelles fonctionnalités ajoutées
```

**Italiano (it-IT):**
```
Novità:
- Correzione di bug e miglioramenti delle prestazioni
- Nuove funzionalità aggiunte
```

**Rumeno (ro):**
```
Noutăți:
- Remediere a erorilor și îmbunătățiri ale performanței
- Funcții noi adăugate
```

#### B. **Controlli Finali**
- [ ] Verifica che la versione sia corretta
- [ ] Controlla che il version code sia maggiore del precedente
- [ ] Rivedi le note di rilascio per ogni lingua
- [ ] Assicurati che non ci siano errori di validazione

### 6. **Pubblicazione**
- Clicca su "Salva" per salvare il rilascio
- Clicca su "Rivedi rilascio" per la revisione finale
- Clicca su "Avvia rilascio in produzione"

## ⚠️ Note Importanti

### Version Code
- **Mai decrementare** il version code
- Ogni rilascio deve avere un version code maggiore del precedente
- Google Play Store usa questo numero per determinare quale versione è più recente

### Version Name
- È la versione visibile agli utenti
- Segui il formato semantico (es: 1.1.8, 1.2.0, 2.0.0)
- Può essere uguale al precedente se stai solo correggendo bug

### Tempi di Pubblicazione
- **Test interno:** Immediato
- **Test chiuso:** Immediato per i tester
- **Produzione:** Può richiedere da poche ore a 2-3 giorni per la revisione

### Backup
- Mantieni sempre una copia di backup del progetto prima di ogni rilascio
- Usa Git per versionare le modifiche

## 🔄 Template Rapido

Per un rilascio veloce, usa questo template:

1. **Aggiorna versioni:**
   - `pubspec.yaml`: `version: 1.1.X`
   - `build.gradle`: `flutterVersionCode = 'X'`

2. **Build:**
   ```bash
   flutter clean && flutter pub get && flutter gen-l10n && flutter build appbundle
   ```

3. **Crea changelog** in `metadata/en-US/changelogs/X.txt`

4. **Carica su Google Play Console** e compila le note di rilascio

5. **Pubblica!**

---

**Ultimo aggiornamento:** Versione 1.1.7 (Version Code: 6)
**Prossimo rilascio:** Versione 1.1.8 (Version Code: 7) 