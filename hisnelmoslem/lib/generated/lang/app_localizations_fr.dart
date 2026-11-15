// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutUs => 'À propos de nous';

  @override
  String get activate => 'Activer';

  @override
  String get activateCounterInstructions =>
      'Pour activer un compteur, allez dans Compteurs puis touchez l\'icône du compteur voulu';

  @override
  String get activeTally => 'Compteur actif';

  @override
  String get add => 'Ajouter';

  @override
  String get addNameToCounter => 'Donnez un nom à votre compteur';

  @override
  String get addNewCounter => 'Ajouter un compteur';

  @override
  String get addReminder => 'Ajouter un rappel';

  @override
  String get alarmEditor => 'Éditeur d\'alarme';

  @override
  String get allow => 'Autoriser';

  @override
  String get allowNotifications => 'Autoriser l\'application à envoyer des notifications ?';

  @override
  String get allowZikrRestoreSession => 'Autoriser la reprise de session de dhikr';

  @override
  String get allowZikrRestoreSessionDesc =>
      'Menu contextuel pour reprendre une session de dhikr non terminée';

  @override
  String get allWords => 'Tous les mots';

  @override
  String get anyWords => 'Un des mots';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get appTitle => 'Hisn ELmoslem';

  @override
  String get areYouSure => 'Êtes-vous sûr ?';

  @override
  String get azkarFilters => 'Filtres des invocations';

  @override
  String get backgroundColor => 'Couleur d\'arrière-plan';

  @override
  String get bookmark => 'Signet';

  @override
  String get brightnessDark => 'Sombre';

  @override
  String get brightnessLight => 'Clair';

  @override
  String get brightnessSystem => 'Système';

  @override
  String get cardIndex => 'Index des cartes';

  @override
  String get cardMode => 'Mode cartes';

  @override
  String get channelInAppName => 'Notification dans l\'application';

  @override
  String get channelInAppNameDesc => 'Pour les notifications internes';

  @override
  String get channelScheduledName => 'Notifications programmées';

  @override
  String get channelScheduledNameDesc => 'Pour les notifications programmées';

  @override
  String get chat => 'Application Hisn ELmoslem | Contact';

  @override
  String get chooseTimeForReminder => 'Veuillez choisir l\'heure du rappel';

  @override
  String get circleEvery => 'Compléter le cercle tous les';

  @override
  String get circular => 'Circulaire';

  @override
  String get clickHere => 'Touchez ici';

  @override
  String get clickToChooseTime => 'Touchez pour régler l\'heure';

  @override
  String get close => 'Fermer';

  @override
  String get menu => 'Menu';

  @override
  String get closeMenu => 'Fermer le menu';

  @override
  String get drawerSectionRead => 'Lecture';

  @override
  String get drawerSectionTools => 'Outils';

  @override
  String get drawerSectionMore => 'Plus';

  @override
  String get commentary => 'Commentaire';

  @override
  String get commentaryBenefit => 'Mérite';

  @override
  String get commentaryHadith => 'Hadith';

  @override
  String get commentarySharh => 'Explication';

  @override
  String get commentaryNotAvailable => 'Aucun texte n\'est encore disponible pour ce dhikr.';

  @override
  String get contact => 'Contact';

  @override
  String get contactDev => 'Contacter le développeur';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get copy => 'Copier';

  @override
  String get count => 'Compte';

  @override
  String get undo => 'Annuler';

  @override
  String get tallyMoreOptions => 'Plus d\'options';

  @override
  String get tallyAutoAdvance => 'Passage automatique';

  @override
  String get tallyAutoAdvanceDesc =>
      'Passer tout seul à un autre compteur pendant que vous comptez.';

  @override
  String get tallyAutoAdvanceOff => 'Désactivé';

  @override
  String get tallyAdvanceWhen => 'Passer au suivant';

  @override
  String get tallyAdvanceEveryCount => 'Après chaque comptage';

  @override
  String get tallyAdvanceEveryCycle => 'Après un cycle complet';

  @override
  String get tallyAddOne => 'Ajouter un';

  @override
  String tallyCountSemantics(String title, int count, int total) {
    return '$title : $count sur $total';
  }

  @override
  String tallyCyclesDone(int count) {
    return 'Cycles : $count';
  }

  @override
  String tallyCountOf(int count, int total) {
    return '$count sur $total';
  }

  @override
  String tallyTotal(int count) {
    return 'Total : $count';
  }

  @override
  String tallyAutoShort(String mode) {
    return 'Auto : $mode';
  }

  @override
  String get tallyReRecord => 'Réenregistrer ma voix';

  @override
  String get tallyCounterReset => 'Compteur remis à zéro';

  @override
  String get tallyAllCountersReset => 'Tous les compteurs remis à zéro';

  @override
  String get tallyPickCounter => 'Choisir un compteur';

  @override
  String get tallyVoiceSection => 'Votre voix';

  @override
  String get tallyVoiceHint =>
      'Enregistrez-vous, puis lancez la lecture et laissez-la compter pour vous.';

  @override
  String tallySessionCounted(int count) {
    return 'Compté par la voix : $count';
  }

  @override
  String get tallySession => 'Session de lecture';

  @override
  String get tallySessionDesc => 'Quand la lecture doit-elle s\'arrêter d\'elle-même ?';

  @override
  String get tallySessionEndless => 'Jusqu\'à ce que je l\'arrête';

  @override
  String get tallySessionEndlessShort => 'Sans limite';

  @override
  String get tallySessionMinutes => 'Pendant une durée définie';

  @override
  String get tallySessionCount => 'Jusqu\'à un nombre de comptages';

  @override
  String tallyMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get tallySessionDone => 'Session de lecture terminée';

  @override
  String get tallyNoRecordingToPlay => 'Ce compteur n\'a pas d\'enregistrement à lire';

  @override
  String get tallyHowManyMinutes => 'Minutes';

  @override
  String get tallyHowManyCounts => 'Comptages';

  @override
  String tallyValueBetween(int min, int max) {
    return 'Saisissez un nombre de $min à $max';
  }

  @override
  String get counterCircleMustBeGreaterThanZero =>
      'Le cercle du compteur doit être supérieur à zéro';

  @override
  String get counterCircleSetToZero =>
      'Nombre de comptages dans un cycle (l\'anneau recommence ensuite)';

  @override
  String get counterName => 'Nom du compteur';

  @override
  String get counters => 'Compteurs';

  @override
  String get counterWillBeDeleted => 'Ce compteur sera supprimé.';

  @override
  String get currentVersion => 'Version actuelle';

  @override
  String get daily => 'Quotidien';

  @override
  String get dashboardArrangement => 'Disposition du tableau de bord';

  @override
  String get deactivate => 'Désactiver';

  @override
  String get decrease => 'Diminuer';

  @override
  String get delete => 'Supprimer';

  @override
  String get digitalCopyOfHisnElmoslem =>
      'Une version numérique de Hisn Elmoslem du réseau Aloka a été utilisée.';

  @override
  String get dislikeAboutApp => 'Ce que je n\'aime pas dans cette application :';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get done => 'Terminé';

  @override
  String get donnotAskAgain => 'Ne plus demander';

  @override
  String get drSaeedBinAliBinWahf => 'Dr Saïd ben Ali ben Wahf Al-Qahtani';

  @override
  String get edit => 'Modifier';

  @override
  String get editCounter => 'Modifier le compteur';

  @override
  String get editImageSize => 'Modifier la taille de l\'image';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String get effectManager => 'Contrôle des effets';

  @override
  String get enableAzkarFilters => 'Activer les filtres des invocations';

  @override
  String get enableWakeLock => 'Garder l\'écran allumé';

  @override
  String get endSuraAliImran => 'Fin de la sourate Al-Imran';

  @override
  String get errorEmailAppOpen => 'Impossible d\'ouvrir l\'application de messagerie';

  @override
  String get errorOccurred => 'Une erreur s\'est produite !';

  @override
  String get everyFriday => 'Tous les vendredis';

  @override
  String get everyMonday => 'Tous les lundis';

  @override
  String get everySaturday => 'Tous les samedis';

  @override
  String get everySunday => 'Tous les dimanches';

  @override
  String get everyThursday => 'Tous les jeudis';

  @override
  String get everyTuesday => 'Tous les mardis';

  @override
  String get everyWednesday => 'Tous les mercredis';

  @override
  String get fakeHadith => 'Faux hadiths';

  @override
  String get fastingMondayReminder => 'Jeûne demain (lundi)';

  @override
  String get fastingThursdayReminder => 'Jeûne demain (jeudi)';

  @override
  String get fastingMondaysThursdaysReminder => 'Rappel du jeûne du lundi et du jeudi';

  @override
  String get favoritesContent => 'favoris';

  @override
  String get favoritesZikr => 'Dhikr favoris';

  @override
  String get featuresToBeAdded => 'Fonctionnalités que j\'aimerais voir ajoutées :';

  @override
  String get fieldIsRequired => 'Ce champ est obligatoire et ne peut pas être vide';

  @override
  String get fixedSizeMode => 'Mode taille fixe';

  @override
  String get fontDecreaseSize => 'Réduire la taille de la police';

  @override
  String get fontIncreaseSize => 'Augmenter la taille de la police';

  @override
  String get fontResetSize => 'Réinitialiser la taille de la police';

  @override
  String get fontSettings => 'Réglages de la police';

  @override
  String get fontType => 'Type de police';

  @override
  String get freeAdFreeAndOpenSourceApp => 'Application gratuite, sans publicité et open source';

  @override
  String get freqAnnual => 'Annuel';

  @override
  String get freqDaily => 'Quotidien';

  @override
  String get freqMonthly => 'Mensuel';

  @override
  String get freqWeekly => 'Hebdomadaire';

  @override
  String get general => 'Général';

  @override
  String get github => 'Code source sur Github';

  @override
  String get goTo => 'Aller à';

  @override
  String get haveBeenRead => 'Lu';

  @override
  String get haveNotOpenedAppLongTime => 'Vous n\'avez pas ouvert l\'application depuis longtemps.';

  @override
  String get haveNotReadAnythingYet => 'Vous n\'avez encore rien lu';

  @override
  String get hisnElmoslem => 'Hisn Elmoslem';

  @override
  String get hisnElmoslemApp => 'Application Hisn Elmoslem';

  @override
  String get hisnElmoslemAppVersion => 'Version de l\'application Hisn ELmoslem';

  @override
  String get hokmAthar => 'Athar';

  @override
  String get hokmDaeif => 'Faible';

  @override
  String get hokmHasan => 'Bon';

  @override
  String get hokmMawdue => 'Forgé';

  @override
  String get hokmSahih => 'Authentique';

  @override
  String get imageQuality => 'Qualité de l\'image';

  @override
  String get imageWidth => 'Largeur de l\'image';

  @override
  String get ignoreNotificationPermission => 'Ignorer l\'autorisation de notification';

  @override
  String get ignoreNotificationPermissionDesc =>
      'Ne pas demander l\'autorisation de notification au lancement de l\'application';

  @override
  String get index => 'Index';

  @override
  String get later => 'Plus tard';

  @override
  String get likeAboutApp => 'Ce que j\'aime dans cette application :';

  @override
  String get message => 'Message';

  @override
  String get misspelled => 'Mal orthographié';

  @override
  String get moreApps => 'Plus d\'applications';

  @override
  String get newText => 'Nouveau';

  @override
  String get next => 'Suivant';

  @override
  String get no => 'Non';

  @override
  String get noActiveCounter => 'Aucun compteur actif';

  @override
  String get noAlarmSetForAnyZikr =>
      'Aucune alarme n\'a été définie pour un dhikr. Pour en définir une, touchez l\'icône d\'alarme à côté du titre du dhikr';

  @override
  String get noMoreResults => 'Plus aucun résultat';

  @override
  String get none => 'Aucun';

  @override
  String get noRemindersFound => 'Aucun rappel trouvé';

  @override
  String get noResultsFound => 'Aucun résultat';

  @override
  String get notes => 'Notes';

  @override
  String get nothingFoundInFavorites => 'Rien dans les favoris';

  @override
  String get notificationPermissionRequired =>
      'Hisn ELmoslem a besoin de l\'autorisation de notification pour envoyer les rappels de dhikr.';

  @override
  String get noTitleMarkedAsFavorite =>
      'Aucun titre de l\'index n\'est marqué comme favori. Touchez l\'icône Favoris sur un titre de l\'index';

  @override
  String get noTitleWithName => 'Aucun titre portant ce nom';

  @override
  String get noZikrSelectedAsFavorite =>
      'Aucun dhikr n\'a été choisi comme favori. Touchez l\'icône en forme de cœur sur un dhikr';

  @override
  String get officialWebsite => 'Site officiel';

  @override
  String get ourProducts => 'Nos produits';

  @override
  String get pageMode => 'Mode pages';

  @override
  String get phoneVibrationAtEveryPraise => 'Vibration du téléphone à chaque glorification';

  @override
  String get phoneVibrationAtSingleZikrEnd => 'Vibration du téléphone à la fin d\'un dhikr';

  @override
  String get phoneVibrationWhenAllZikrEnd => 'Vibration du téléphone à la fin de tous les dhikrs';

  @override
  String get preciseTiming => 'Horaire précis';

  @override
  String get preciseTimingDesc => 'Pour que les rappels arrivent à l\'heure exacte (Android 13+).';

  @override
  String get permissionGranted => 'Accordée';

  @override
  String get permissionDenied => 'Refusée';

  @override
  String get permissionsRequired => 'Autorisations requises';

  @override
  String get prayForUsAndParents => 'Priez pour nous et pour nos parents.';

  @override
  String get prefPraiseWithVolumeKeys => 'Compter avec les touches de volume';

  @override
  String get prefPraiseWithVolumeKeysDesc =>
      'Compter avec les touches de volume en mode pages et dans le compteur';

  @override
  String get previous => 'Précédent';

  @override
  String get progressDeletedCannotUndo =>
      'Votre progression sera supprimée et vous ne pourrez pas l\'annuler';

  @override
  String get prophetSaidLiesIntentional =>
      'Le Prophète (que la paix et les bénédictions d\'Allah soient sur lui) a dit : « Quiconque ment sur moi délibérément, qu\'il prenne sa place en Enfer. »';

  @override
  String get quranPagesFromAndroidQuran => 'Les pages du Coran proviennent d\'Android Quran';

  @override
  String get rateTheApp => 'Application Hisn ELmoslem | Noter l\'application';

  @override
  String get readAllContent => 'Vous avez tout lu';

  @override
  String get reminderRemoved => 'Rappel supprimé';

  @override
  String get reminders => 'Rappels';

  @override
  String get remindersManager => 'Gestion des rappels';

  @override
  String get report => 'Signaler';

  @override
  String get reportBugsRequestFeatures =>
      'Signaler des bugs et demander de nouvelles fonctionnalités';

  @override
  String get requiresAppRestart => 'Nécessite de redémarrer l\'application';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resetAllCounters => 'Réinitialiser tous les compteurs ?';

  @override
  String get resetZikr => 'Réinitialiser le dhikr';

  @override
  String get reviewIndexOfBook => 'Veuillez revoir l\'index du livre';

  @override
  String get search => 'Rechercher';

  @override
  String get searchFilters => 'Filtres de recherche';

  @override
  String get select => 'Choisir';

  @override
  String get selectAzkarHokmFilters => 'Choisir le statut des invocations';

  @override
  String get selectAzkarSource => 'Choisir la source des invocations';

  @override
  String get selectColor => 'Choisir une couleur';

  @override
  String get sendEmail => 'Envoyer un e-mail';

  @override
  String get setMessageForYou => 'Définir un message pour vous-même';

  @override
  String get settings => 'Paramètres';

  @override
  String get share => 'Partager';

  @override
  String get shareAsImage => 'Partager en image';

  @override
  String get shareZikr => 'Partager le dhikr';

  @override
  String get shouldBe => 'Il devrait être :';

  @override
  String get showDiacritics => 'Afficher les voyelles';

  @override
  String get showFadl => 'Afficher le mérite';

  @override
  String get showSourceOfZikr => 'Afficher la source du dhikr';

  @override
  String get shuffle => 'Mélanger';

  @override
  String get shuffleModeActivated => 'Mode aléatoire activé';

  @override
  String get shuffleModeDeactivated => 'Mode aléatoire désactivé';

  @override
  String get skip => 'Passer';

  @override
  String get soundEffectAtEveryPraise => 'Effet sonore à chaque glorification';

  @override
  String get soundEffectAtSingleZikrEnd => 'Effet sonore à la fin d\'un dhikr';

  @override
  String get soundEffectVolume => 'Volume des effets sonores';

  @override
  String get soundEffectWhenAllZikrEnd => 'Effet sonore à la fin de tous les dhikrs';

  @override
  String get sourceAbuDawood => 'Sunan Abi Dawud';

  @override
  String get sourceAdDarami => 'Sunan ad-Darimi';

  @override
  String get sourceAhmad => 'Musnad Ahmad ibn Hanbal';

  @override
  String get sourceAnNasai => 'As-Sunan as-Sughra d\'an-Nasa\'i';

  @override
  String get sourceAthar => 'Athar';

  @override
  String get sourceAtTabarani => 'At-Tabarani';

  @override
  String get sourceAtTirmidhi => 'Sunan at-Tirmidhi';

  @override
  String get sourceBayhaqi => 'Sunan al-Bayhaqi';

  @override
  String get sourceHakim => 'Al-Mustadrak ala as-Sahihayn';

  @override
  String get sourceIbnMajah => 'Sunan Ibn Majah';

  @override
  String get sourceIbnSunny => 'Ibn as-Sunni';

  @override
  String get sourceMalik => 'Al-Muwatta de l\'imam Malik';

  @override
  String get sourceQuran => 'Coran';

  @override
  String get sourceSahihBukhari => 'Sahih al-Bukhari';

  @override
  String get sourceSahihMuslim => 'Sahih Muslim';

  @override
  String get spellingErrorIn => 'Il y a une faute d\'orthographe dans';

  @override
  String get start => 'Démarrer';

  @override
  String get subject => 'Objet';

  @override
  String get subtitleColor => 'Couleur du sous-titre';

  @override
  String get suraAlKahf => 'Sourate Al-Kahf';

  @override
  String get suraAlKahfReminder => 'Rappel de la sourate Al-Kahf';

  @override
  String get suraAlMulk => 'Sourate Al-Mulk';

  @override
  String get suraAsSajdah => 'Sourate As-Sajda';

  @override
  String get tally => 'Compteur';

  @override
  String get tallyActualCounterDesc => 'Valeur réelle du compteur';

  @override
  String get tallyEditor => 'Éditeur de compteur';

  @override
  String get text => 'Texte';

  @override
  String get textColor => 'Couleur du texte';

  @override
  String get themeAppColor => 'Couleur de l\'application';

  @override
  String get themeApperance => 'Apparence';

  @override
  String get themeBackgroundColor => 'Couleur d\'arrière-plan';

  @override
  String get themeManager => 'Contrôle du thème';

  @override
  String get themeOverrideBackground => 'Remplacer l\'arrière-plan';

  @override
  String get themeSelectColor => 'Choisir une couleur';

  @override
  String get themeUseMaterial3 => 'Utiliser Material 3';

  @override
  String get themeUserOldTheme => 'Utiliser l\'ancien thème';

  @override
  String get times => 'Fois';

  @override
  String get title => 'Titre';

  @override
  String get titleColor => 'Couleur du titre';

  @override
  String get trueBlackTheme => 'Thème noir pur';

  @override
  String get typical => 'Standard';

  @override
  String get updatesHistory => 'Historique des mises à jour';

  @override
  String get useHindiDigits => 'Utiliser les chiffres arabes orientaux';

  @override
  String get valueMustBeGreaterThanZero => 'La valeur doit être supérieure à zéro';

  @override
  String get version => 'Version';

  @override
  String get yes => 'Oui';

  @override
  String get zikrContent => 'Contenu du dhikr';

  @override
  String get zikrIndex => 'Index des dhikrs';

  @override
  String get zikrViewerRestoreSessionMsg =>
      'Une session précédente a été trouvée. Voulez-vous la reprendre ?';

  @override
  String get audioPlayerSpeed => 'Vitesse de lecture';

  @override
  String get audioPlayerVolume => 'Volume';

  @override
  String get audioPlayerDelay => 'Délai entre les invocations';

  @override
  String get audioPlayerDelayNone => 'Aucun délai';

  @override
  String get audioPlayerDelayByPrevious => 'Identique au dhikr précédent';

  @override
  String get audioPlayerDelayFixed => 'Durée fixe';

  @override
  String get audioPlayerDelaySeconds => 'Secondes';

  @override
  String get audioPlayerSettings => 'Réglages audio';

  @override
  String get audioReciter => 'Récitateur';

  @override
  String get audioBundledReciterNote => 'Enregistrements inclus dans l\'application';

  @override
  String get audioAllowStream => 'Écouter en ligne';

  @override
  String get audioAllowStreamDesc =>
      'Lire depuis Internet les enregistrements qui ne sont pas sur le téléphone. Cela peut consommer des données mobiles.';

  @override
  String get audioDownloadAll => 'Tout télécharger';

  @override
  String audioFilesStatus(int done, int total, String size) {
    return '$done fichiers sur $total · $size';
  }

  @override
  String get audioDeleteDownloads => 'Supprimer les téléchargements';

  @override
  String audioDeleteConfirm(String name) {
    return 'Supprimer de ce téléphone les enregistrements de $name ?';
  }

  @override
  String get audioDownloadConfirmTitle => 'Télécharger les enregistrements';

  @override
  String audioDownloadConfirmBody(int count, String size) {
    return '$count fichiers, environ $size. Cela peut consommer des données mobiles.';
  }

  @override
  String audioDownloadConfirmBodyNoSize(int count) {
    return '$count fichiers. Cela peut consommer des données mobiles.';
  }

  @override
  String audioDownloading(int done, int total) {
    return 'Téléchargement $done sur $total';
  }

  @override
  String audioDownloadPaused(int done, int total) {
    return 'En pause à $done sur $total';
  }

  @override
  String audioDownloadFailedFiles(int count) {
    return '$count fichiers n\'ont pas pu être téléchargés';
  }

  @override
  String get audioDownloadPause => 'Pause';

  @override
  String get audioDownloadResume => 'Reprendre';

  @override
  String get audioDownloadRetry => 'Réessayer';

  @override
  String get audioDownloadTitleAction => 'Télécharger l\'audio de ce titre';

  @override
  String get audioNothingToDownload =>
      'Rien à télécharger : tout est déjà sur le téléphone ou n\'est pas disponible.';

  @override
  String get audioDownloadStarted => 'Téléchargement démarré';

  @override
  String get audioDownloadDone => 'Téléchargement terminé';

  @override
  String get audioDownloadAlreadyRunning => 'Un autre téléchargement est déjà en cours';

  @override
  String get audioAvailabilityNote =>
      'Tous les dhikrs n\'ont pas un enregistrement de chaque récitateur. Un dhikr sans enregistrement lit celui inclus dans l\'application s\'il existe, sinon il n\'a pas d\'audio.';

  @override
  String get audioLoading => 'Chargement de l\'audio…';

  @override
  String get downloadCenter => 'Centre de téléchargement';

  @override
  String get downloadCenterDesc =>
      'Choisissez un récitateur, puis téléchargez tous ses enregistrements ou seulement certains titres pour écouter sans Internet.';

  @override
  String get audioUseReciter => 'Utiliser ce récitateur';

  @override
  String get audioReciterInUse => 'Récitateur actuel';

  @override
  String get audioDeleteAll => 'Tout supprimer';

  @override
  String audioDeleteTitleConfirm(String title) {
    return 'Supprimer l\'audio téléchargé de « $title » ? Les titres qui partagent ses enregistrements sont aussi concernés.';
  }

  @override
  String get audioDownloadTooltip => 'Télécharger';

  @override
  String get audioNoTitles => 'Aucun enregistrement n\'est disponible pour ce récitateur.';

  @override
  String get audioTitleDownloaded => 'Téléchargé';

  @override
  String get audioNotDownloaded => 'Non téléchargé';

  @override
  String get aboutAudioSourceTitle => 'Source audio';

  @override
  String get aboutAudioSourceDesc =>
      'Les récitateurs et les enregistrements du centre de téléchargement proviennent du site du Dr Saïd ben Ali ben Wahf Al-Qahtani (binwahaf.com).';

  @override
  String get vibrationDuration => 'Durée de vibration (ms)';

  @override
  String get saveToGallery => 'Enregistrer dans la galerie';

  @override
  String get imageSavedSuccessfully => 'Image enregistrée avec succès';

  @override
  String get backupAndRestore => 'Sauvegarde et restauration';

  @override
  String get backupData => 'Sauvegarder les données';

  @override
  String get restoreData => 'Restaurer les données';

  @override
  String get backupSuccess => 'Sauvegarde réussie';

  @override
  String get restoreSuccessRestart => 'Restauration réussie. Veuillez redémarrer l\'application.';

  @override
  String get backupFailed => 'Échec de la sauvegarde';

  @override
  String get restoreFailed => 'Échec de la restauration';

  @override
  String get showAudioBar => 'Afficher la barre audio';

  @override
  String get showAudioBarDesc =>
      'Afficher ou masquer la barre de contrôle audio dans la page du dhikr';

  @override
  String get customAzkar => 'Invocations personnalisées';

  @override
  String get customAzkarEmptyTitle => 'Aucun titre personnalisé pour l\'instant';

  @override
  String get customAzkarEmptyDesc =>
      'Créez votre propre titre et remplissez-le avec les invocations que vous aimez. Vos invocations d\'origine ne sont jamais modifiées.';

  @override
  String customItemsCount(int count) {
    return '$count invocations';
  }

  @override
  String get customTitleDeleteConfirm => 'Supprimer ce titre ?';

  @override
  String get customTitleDeleteDetails =>
      'Le titre et son rappel seront supprimés. Les invocations d\'origine ne sont pas affectées.';

  @override
  String get customTitleDeleted => 'Titre supprimé';

  @override
  String get customTitleHasReminder => 'Le rappel est activé';

  @override
  String get newCustomTitle => 'Nouveau titre';

  @override
  String get createFromScratch => 'Partir de zéro';

  @override
  String get createFromScratchDesc => 'Un titre vide que vous remplissez vous-même';

  @override
  String get createFromExisting => 'Partir d\'un titre existant';

  @override
  String get createFromExistingDesc =>
      'Copier les invocations d\'un titre de Hisn al-Muslim, puis les modifier librement';

  @override
  String get editCustomTitle => 'Modifier le titre';

  @override
  String get customTitleName => 'Nom du titre';

  @override
  String get customTitleDescription => 'Description (facultatif)';

  @override
  String get addZikr => 'Ajouter un dhikr';

  @override
  String get newZikr => 'Nouveau dhikr';

  @override
  String get myZikrs => 'Mes dhikrs';

  @override
  String get fromHisn => 'De Hisn al-Muslim';

  @override
  String get zikrText => 'Texte du dhikr';

  @override
  String get zikrSource => 'Source (facultatif)';

  @override
  String get zikrFadl => 'Mérite (facultatif)';

  @override
  String get zikrCountLabel => 'Répétitions';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String addSelected(int count) {
    return 'Ajouter la sélection ($count)';
  }

  @override
  String get noCustomZikrs => 'Vous n\'avez encore créé aucun dhikr';

  @override
  String get noItemsInTitle => 'Ajoutez au moins un dhikr à ce titre';

  @override
  String get titleNameRequired => 'Veuillez saisir un nom de titre';

  @override
  String get zikrTextRequired => 'Veuillez saisir le texte du dhikr';

  @override
  String get discardChangesTitle => 'Abandonner les modifications ?';

  @override
  String get discardChangesDetails => 'Vos modifications non enregistrées seront perdues.';

  @override
  String get savedCopyBadge => 'Copie enregistrée';

  @override
  String get originalBadge => 'Original';

  @override
  String get customBadge => 'Personnalisé';

  @override
  String get removeFromTitle => 'Retirer';

  @override
  String get dragToReorder => 'Faites glisser pour réorganiser';

  @override
  String get countDecrease => 'Diminuer';

  @override
  String get countIncrease => 'Augmenter';

  @override
  String get deleteCustomZikrConfirm => 'Supprimer ce dhikr ?';

  @override
  String deleteCustomZikrUsedIn(String titles) {
    return 'Il est utilisé dans : $titles. Il sera retiré de ces titres.';
  }

  @override
  String get searchHisnHint => 'Rechercher dans Hisn al-Muslim';

  @override
  String get chooseOriginalTitle => 'Choisir un titre';

  @override
  String get dashboardArrangementHint =>
      'Maintenez et faites glisser un onglet pour changer l\'ordre des onglets de l\'accueil.';

  @override
  String get dashboardArrangementPreview => 'Ordre sur l\'écran d\'accueil';

  @override
  String get dragToReorderTab => 'Faites glisser pour réorganiser';

  @override
  String get dashboardArrangementReset => 'Rétablir l\'ordre par défaut';

  @override
  String get zikrOptions => 'Options';

  @override
  String get recordVoice => 'Enregistrer ma voix';

  @override
  String get recordSheetTitle => 'Enregistrez votre voix';

  @override
  String get recordStart => 'Démarrer l\'enregistrement';

  @override
  String get recordStop => 'Arrêter l\'enregistrement';

  @override
  String get recordHintIdle => 'Touchez le microphone, puis récitez le dhikr.';

  @override
  String get recordHintRecording => 'Enregistrement… touchez pour arrêter';

  @override
  String get recordPermissionDenied =>
      'L\'accès au microphone est nécessaire pour enregistrer. Autorisez-le dans les paramètres de votre appareil.';

  @override
  String get recordFailed => 'Impossible d\'enregistrer. Veuillez réessayer.';

  @override
  String get recordListen => 'Écouter votre enregistrement';

  @override
  String get recordUse => 'Utiliser cet enregistrement';

  @override
  String get recordAgain => 'Réenregistrer';

  @override
  String get recordDiscardTitle => 'Abandonner cet enregistrement ?';

  @override
  String get recordDiscardDetails => 'L\'enregistrement que vous venez de faire sera supprimé.';

  @override
  String get recordCurrent => 'Votre enregistrement';

  @override
  String get recordOriginal => 'Récitation d\'origine';

  @override
  String get recordDelete => 'Supprimer mon enregistrement';

  @override
  String get recordDeleteConfirmTitle => 'Supprimer votre enregistrement ?';

  @override
  String get recordDeleteConfirmOriginal => 'La récitation d\'origine sera de nouveau lue.';

  @override
  String get recordDeleteConfirmCustom => 'Ce dhikr n\'aura plus d\'audio.';

  @override
  String get recordMyVoiceBadge => 'Ma voix';

  @override
  String get recordPlay => 'Lire';

  @override
  String get recordPause => 'Pause';

  @override
  String get audioPlay => 'Lire l\'audio';

  @override
  String get audioPause => 'Mettre l\'audio en pause';

  @override
  String get audioStop => 'Arrêter l\'audio';

  @override
  String get zikrTapToCount => 'Touchez pour compter';

  @override
  String get zikrDone => 'Terminé';

  @override
  String get shareImageCustomize => 'Personnaliser';

  @override
  String get shareImageColors => 'Couleurs';

  @override
  String get shareImageContent => 'Contenu';

  @override
  String get shareImageColorTarget => 'Choisissez ce qu\'il faut colorer';

  @override
  String get shareImageTextColor => 'Couleur du texte';

  @override
  String get shareImagePresets => 'Couleurs prêtes à l\'emploi';

  @override
  String get shareImagePresetDark => 'Sombre';

  @override
  String get shareImagePresetLight => 'Clair';

  @override
  String get presetClassicNight => 'Nuit classique';

  @override
  String get presetEmeraldNight => 'Nuit émeraude';

  @override
  String get presetMidnightGold => 'Or de minuit';

  @override
  String get presetDeepOcean => 'Océan profond';

  @override
  String get presetRoyalPurple => 'Pourpre royal';

  @override
  String get presetCharcoalCoral => 'Anthracite corail';

  @override
  String get presetParchment => 'Parchemin';

  @override
  String get presetMintGarden => 'Jardin de menthe';

  @override
  String get presetCleanWhite => 'Blanc pur';

  @override
  String get presetRoseDawn => 'Aube rosée';

  @override
  String get presetSkyMorning => 'Matin d\'azur';

  @override
  String get shareImageColorCurrent => 'Actuelle';

  @override
  String get shareImageColorNew => 'Nouvelle';

  @override
  String get shareImageHexCode => 'Code hexadécimal';

  @override
  String get shareQualityStandard => 'Standard';

  @override
  String get shareQualityHigh => 'Élevée';

  @override
  String get shareQualityMax => 'Maximale';

  @override
  String shareImageQualityHint(int width) {
    return '$width px de large';
  }

  @override
  String get galleryPermissionRequired =>
      'Autorisez l\'accès à vos photos pour enregistrer l\'image';

  @override
  String get whatsNewTitle => 'Nouveautés';

  @override
  String get whatsNewHeroBadge => 'Plus grosse mise à jour';

  @override
  String get whatsNewCustomTitle => 'Vos propres invocations';

  @override
  String get whatsNewCustomDesc =>
      'Créez vos propres titres, remplissez-les avec vos invocations ou celles de Hisn, définissez le nombre de répétitions et un rappel, et enregistrez votre propre voix pour n\'importe quel dhikr. Inclus dans la recherche, les favoris et les sauvegardes.';

  @override
  String get whatsNewDownloadsTitle => 'Centre de téléchargement';

  @override
  String get whatsNewDownloadsDesc =>
      'Choisissez un récitateur (Rashid Al-Hulaibah, Sulaiman Al-Shuwaihi ou Hamad Al-Duraihem) et téléchargez tout le livre ou un seul titre pour l\'écouter hors ligne, ou écoutez-le directement en ligne.';

  @override
  String get whatsNewTallyTitle => 'Compteur repensé';

  @override
  String get whatsNewTallyDesc =>
      'Un écran de comptage plus clair, avec une lecture vocale qui compte pour vous, le passage automatique et l\'annulation.';

  @override
  String get whatsNewViewerTitle => 'Nouvel écran de dhikr';

  @override
  String get whatsNewViewerDesc =>
      'Une seule barre en bas pour l\'audio et les options, et des touches de volume qui restent sous contrôle.';

  @override
  String get whatsNewShareTitle => 'De meilleures images partagées';

  @override
  String get whatsNewShareDesc =>
      'Des couleurs prêtes à l\'emploi, des réglages de qualité et une image nette qui contient toujours tout le dhikr.';

  @override
  String get whatsNewHomeTitle => 'Un accueil à votre façon';

  @override
  String get whatsNewHomeDesc =>
      'Un tiroir d\'accueil déplaçable et une disposition du tableau de bord repensée, avec retour à l\'ordre par défaut.';

  @override
  String get whatsNewContentTitle => 'Corrections';

  @override
  String get whatsNewContentDesc =>
      'Fautes corrigées, explications manquantes complétées et certains audios corrigés.';

  @override
  String get whatsNewTranslationsTitle => 'Traduction et transcription';

  @override
  String get whatsNewTranslationsDesc =>
      'Lisez chaque invocation en anglais ou en français : le sens et la transcription en lettres latines s\'affichent sous le texte arabe. Choisissez la langue et ce qui s\'affiche dans les réglages.';

  @override
  String get whatsNewFrenchTitle => 'Le français arrive';

  @override
  String get whatsNewFrenchDesc =>
      'L\'application est disponible en français, et chaque langue s\'affiche sous son nom. Sans choix, elle suit la langue de votre appareil.';

  @override
  String get translationSettings => 'Traduction';

  @override
  String get translationLanguage => 'Langue de la traduction';

  @override
  String get translationLanguageAuto => 'Automatique';

  @override
  String get translationLanguageAutoDesc =>
      'Suit la langue de l\'appareil, anglais si elle n\'est pas disponible';

  @override
  String translationSource(String source) {
    return 'Source : $source';
  }

  @override
  String get translationFallbackHint => 'Affiché en anglais car non disponible dans votre langue';

  @override
  String get translationPartialHint => 'Cette traduction peut couvrir plus que le texte ci-dessus.';

  @override
  String get translationShowMeaning => 'Afficher le sens';

  @override
  String get translationShowTranslit => 'Afficher la translittération';

  @override
  String get translationShowTitles => 'Afficher les titres traduits';

  @override
  String get aboutTranslationsTitle => 'Traductions';

  @override
  String get aboutTranslationsDesc =>
      'Les traductions et translittérations en anglais et en français proviennent de hisnmuslim.com.';

  @override
  String get fastingReminderTime => 'Heure du rappel';

  @override
  String get fastingRemindSameDay => 'Rappeler le jour même';

  @override
  String get fastingRemindSameDayDesc =>
      'Désactivé : la veille au soir. Activé : à l\'heure choisie le jour du jeûne.';

  @override
  String get fastingMondayTodayReminder => 'Jeûne aujourd\'hui (lundi)';

  @override
  String get fastingThursdayTodayReminder => 'Jeûne aujourd\'hui (jeudi)';

  @override
  String get morningAzkarReminder => 'Rappel des invocations du matin';

  @override
  String get eveningAzkarReminder => 'Rappel des invocations du soir';

  @override
  String get presetReminderDesc => 'Chaque jour. Changez l\'heure dans le gestionnaire de rappels.';
}
