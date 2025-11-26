The app simple transforms ebooks into audiobooks that the app can play.
- uses firebase to store the structured text files

|**Screen**|**Purpose**|**Key Features**|
|---|---|---|
|**1. Library (Home)**|Displays the list of all files the user has processed or imported.|Simple list of **Ebooks** (source files) and **Audiobooks** (finished MP3s). Each item shows Title, Author, and Status (e.g., "Awaiting Review," "Ready to Play").|
|**2. Settings**|Manages application preferences.|Default TTS voice, speed, theme.|

---

| **Screen**                                 | **Purpose**                                                                                                                       | **Key Features**                                                                                                                                                                             |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **3. Conversion Flow Screen (Multi-Step)** | A single page that manages the entire file upload, text extraction, review, configuration, and processing lifecycle for one book. | This screen will dynamically change its UI based on the current step: **a) File Picker** $\rightarrow$ **b) Text Editor** $\rightarrow$ **c) Audio Config** $\rightarrow$ **d) Processing**. |
| **4. Audiobook Player**                    | The dedicated screen for listening to a completed, single audio file.                                                             | Standard Play/Pause, Time Scrubber, Playback Speed.                                                                                                                                          |



# Screens
- includes only screens

# Services
- Includes database for firebase
- includes OCR/on-device text recognition from firebase
- includes TTS service 

# Models
- includes all class files and all functions manipulating it


### Note
- for epubreader package, it is called epubx, so we use "import 'package:epubx/epubx.dart';"