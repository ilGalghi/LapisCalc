# Metadata LapisCalc

Questa cartella contiene tutti i metadata necessari per la distribuzione dell'app sui vari store.

## Struttura

```
metadata/
├── store_listings/          # Descrizioni per gli store per ogni lingua
│   ├── en-US/              # English (default)
│   ├── it-IT/              # Italiano  
│   ├── es-ES/              # Español
│   ├── fr-FR/              # Français
│   └── ro-RO/              # Română
├── screenshots/            # Screenshot dell'app
│   ├── phone/             # Screenshot per telefoni
│   └── tablet/            # Screenshot per tablet (se necessari)
├── app_icons/             # Icone dell'app per diversi store
└── release_notes/         # Note di rilascio per versione

```

## File per ogni lingua in store_listings/

- `short_description.txt` - Descrizione breve (max 80 caratteri per Google Play)
- `full_description.txt` - Descrizione completa (max 4000 caratteri per Google Play)
- `title.txt` - Titolo dell'app (se diverso dal nome base)
- `keywords.txt` - Parole chiave per ottimizzazione ASO

## Screenshot

### Convenzioni di denominazione
- `01_calculator.png` - Screenshot calcolatrice principale
- `02_converter.png` - Screenshot convertitore unità
- `03_date_calc.png` - Screenshot calcolatrice date
- `04_settings.png` - Screenshot impostazioni (opzionale)

### Specifiche tecniche
- **Telefoni**: 1080x1920px o 1080x2340px (16:9 o 19.5:9)
- **Tablet**: 1200x1920px o simili
- Formato: PNG con sfondo opaco
- Dimensione max: 8MB per immagine

## Lingue supportate

Le lingue devono corrispondere a quelle definite in:
- `lib/l10n/` (localizzazioni app)
- `pubspec.yaml` (configurazione Flutter)

Attualmente supportate:
- 🇺🇸 English (en-US) - lingua base
- 🇮🇹 Italiano (it-IT)
- 🇪🇸 Español (es-ES)
- 🇫🇷 Français (fr-FR)
- 🇷🇴 Română (ro-RO)

## Manutenzione

Quando si aggiunge una nuova lingua:
1. Creare cartella in `store_listings/[codice-lingua]/`
2. Aggiungere tutti i file descrittivi
3. Aggiornare questo README
4. Verificare corrispondenza con `lib/l10n/`

Quando si aggiorna l'app:
1. Aggiornare screenshot se necessario
2. Aggiornare descrizioni se ci sono nuove funzionalità
3. Aggiungere note di rilascio in `release_notes/`
