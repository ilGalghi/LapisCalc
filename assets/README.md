# Assets LapisCalc

Questa cartella contiene tutte le risorse statiche utilizzate nell'applicazione.

## Struttura

```
assets/
├── icons/                  # Icone dell'applicazione
│   ├── app/               # Icone dell'app (launcher, etc.)
│   │   ├── launcher_icon.png         # Icona principale (177KB)
│   │   ├── launcher_icon_fg.png      # Foreground per icona adattiva (77KB)
│   │   └── launcher_icon_sq.png      # Icona quadrata (174KB)
│   └── ui/                # Icone per l'interfaccia utente
│       ├── github-mark.svg           # Logo GitHub (tema chiaro)
│       └── github-mark-white.svg     # Logo GitHub (tema scuro)
├── images/                # Immagini varie (attualmente vuota)
├── fonts/                 # Font personalizzati
│   └── Manrope/
│       └── Manrope-Regular.ttf       # Font principale dell'app
└── data/                  # Dati statici (se necessari in futuro)
```

## Icone App

### Specifiche tecniche
- **launcher_icon.png**: Icona principale 512x512px
- **launcher_icon_fg.png**: Foreground per icone adattive Android
- **launcher_icon_sq.png**: Variante quadrata per alcuni contesti

### Utilizzo
Le icone app sono configurate in `pubspec.yaml` sotto `flutter_launcher_icons`:
- Android: usa `launcher_icon_fg.png`
- Windows/macOS: usa `launcher_icon.png`

## Icone UI

### GitHub
- **github-mark.svg**: Logo per tema chiaro
- **github-mark-white.svg**: Logo per tema scuro

Utilizzate in `lib/pages/settings_page.dart` nella sezione About (attualmente commentata).

## Font

### Manrope
Font sans-serif moderno utilizzato come font principale dell'app.
- Peso: Regular (400)
- Licenza: [SIL Open Font License](https://scripts.sil.org/OFL)

Configurato in `pubspec.yaml` sotto `fonts`.

## Ottimizzazione

### Dimensioni file
- Mantenere le immagini sotto 1MB quando possibile
- Usare SVG per icone semplici
- Comprimere PNG senza perdita di qualità

### Naming convention
- Usare snake_case per i nomi file
- Includere dimensioni nel nome se rilevanti
- Essere descrittivi: `launcher_icon_fg.png` vs `icon.png`

## Aggiunta nuovi asset

1. Posizionare i file nella cartella appropriata
2. Aggiornare `pubspec.yaml` se necessario
3. Aggiornare questo README
4. Verificare che i path nel codice siano corretti

## Path nei file Dart

Quando si riferiscono asset nel codice:
```dart
// Corretto
'assets/icons/ui/github-mark.svg'
'assets/fonts/Manrope/Manrope-Regular.ttf'

// Evitare path relativi confusi
'../assets/icon.png'
```
