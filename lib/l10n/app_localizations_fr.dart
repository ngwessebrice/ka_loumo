// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ka-Loumo';

  @override
  String get chat => 'Discussion';

  @override
  String get messages => 'Messages';

  @override
  String get chatWithSeller => 'Discuter avec le vendeur';

  @override
  String get productSold => 'Produit vendu';

  @override
  String get markAsSold => 'Marquer comme vendu';

  @override
  String get openingChat => 'Ouverture de la discussion...';

  @override
  String get noMessagesYet => 'Aucun message pour l’instant';

  @override
  String get typeMessage => 'Écrire un message...';

  @override
  String get sold => 'VENDU';

  @override
  String get description => 'Description';

  @override
  String get sellerInfo => 'Informations du vendeur';

  @override
  String get searchProducts => 'Rechercher un produit...';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Ka-Loumo';

  @override
  String get onboardingWelcomeDesc =>
      'La marketplace premium de Guinée Conakry.';

  @override
  String get onboardingBuySellTitle => 'Achetez et vendez facilement';

  @override
  String get onboardingBuySellDesc =>
      'Publiez rapidement — trouvez des clients encore plus vite.';

  @override
  String get onboardingChatTitle => 'Discutez et connectez-vous';

  @override
  String get onboardingChatDesc =>
      'Négociez, discutez et finalisez vos ventes en toute sécurité.';

  @override
  String get btnNext => 'Suivant';

  @override
  String get btnGetStarted => 'Commencer';

  @override
  String get btnSkip => 'Passer';

  @override
  String get loginSubtitle => 'Connectez-vous à votre marketplace';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get loginHint => 'Connectez-vous avec votre numéro ou votre email.';

  @override
  String get phone => 'Téléphone';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get sendOtp => 'Envoyer le code';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get login => 'Connexion';

  @override
  String get noAccount => 'Vous n’avez pas de compte ?';

  @override
  String get register => 'Créer un compte';

  @override
  String get enterEmailFirst => 'Entrez d’abord votre email';

  @override
  String resetLinkSent(Object email) {
    return 'Lien de réinitialisation envoyé à $email';
  }

  @override
  String get resetFailed => 'Impossible d’envoyer l’email de réinitialisation';

  @override
  String get emailAndPasswordRequired => 'Email et mot de passe requis';

  @override
  String get emailLoginFailed => 'Connexion email échouée';

  @override
  String get phoneEnterNumber => 'Entrez votre numéro de téléphone';

  @override
  String get otpFailed => 'Échec de l’envoi du code';

  @override
  String get language => 'Langue';

  @override
  String get registerTitle => 'Créer votre compte';

  @override
  String get registerSubtitle => 'Vendez et achetez sur Ka-Loumo.';

  @override
  String get registerFullName => 'Nom complet';

  @override
  String get registerEmailOptional => 'E-mail (optionnel)';

  @override
  String get registerPhone224 => 'Numéro de téléphone (+224)';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerCreateAccountBtn => 'Créer un compte';

  @override
  String get registerAlreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get msgFullNameRequired => 'Le nom complet est requis';

  @override
  String get msgPhoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get msgPhoneMustStart224 => 'Le numéro doit commencer par +224';

  @override
  String get msgPasswordRequired => 'Le mot de passe est requis';

  @override
  String get msgPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get msgAccountCreated => 'Compte créé avec succès 🎉';

  @override
  String get msgRegistrationFailed => 'Échec de l’inscription';

  @override
  String get otpVerifyPhoneTitle => 'Vérifier le téléphone';

  @override
  String get otpEnterVerificationCodeTitle =>
      'Saisissez le code de vérification';

  @override
  String otpSentTo(String phone) {
    return 'Nous avons envoyé un code au $phone';
  }

  @override
  String get otpCodeLabel => 'Code à 6 chiffres';

  @override
  String get otpVerifyBtn => 'Vérifier';

  @override
  String get otpEnterCode => 'Saisissez le code';

  @override
  String get otpInvalidCode => 'Code invalide';

  @override
  String get catAll => 'Tous';

  @override
  String get catPhones => 'Téléphones';

  @override
  String get catFashion => 'Mode';

  @override
  String get catCars => 'Voitures';

  @override
  String get catElectronics => 'Électronique';

  @override
  String get popularItems => 'Articles populaires';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get badgeNew => 'Neuf';

  @override
  String get explore => 'Explorer';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get untitled => 'Sans titre';

  @override
  String get catRealEstate => 'Immobilier';

  @override
  String get home => 'Accueil';

  @override
  String get profile => 'Profil';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get failedToLoadChats => 'Impossible de charger les conversations';

  @override
  String get noConversationsYet => 'Aucune conversation pour le moment';

  @override
  String get deleteConversationTitle => 'Supprimer la conversation ?';

  @override
  String get deleteConversationBody =>
      'Cela la retirera de votre boîte de réception. Vous pourrez la recréer plus tard en discutant à nouveau.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get userFallback => 'Utilisateur';

  @override
  String get productFallback => 'Produit';

  @override
  String get timeNow => 'maintenant';

  @override
  String get upload => 'Publier';

  @override
  String get photos => 'Photos';

  @override
  String get details => 'Détails';

  @override
  String get title => 'Titre';

  @override
  String get titleHint => 'ex. iPhone 13 Pro Max';

  @override
  String get titleRequired => 'Le titre est obligatoire.';

  @override
  String get titleTooShort => 'Le titre est trop court.';

  @override
  String get priceGNF => 'Prix (GNF)';

  @override
  String get priceHint => 'ex. 650000';

  @override
  String get priceRequired => 'Le prix est obligatoire.';

  @override
  String get enterValidPrice => 'Entrez un prix valide.';

  @override
  String get descriptionHint =>
      'Ajoutez des détails : état, accessoires, défauts, raison de vente…';

  @override
  String get descriptionRequired => 'La description est obligatoire.';

  @override
  String get descriptionTooShort => 'La description est trop courte.';

  @override
  String get categoryAndLocation => 'Catégorie et lieu';

  @override
  String get category => 'Catégorie';

  @override
  String get condition => 'État';

  @override
  String get location => 'Lieu';

  @override
  String get addProductTip =>
      'Astuce : de bonnes photos + des détails clairs = plus d’acheteurs.';

  @override
  String get addAtLeastOnePhoto => 'Veuillez ajouter au moins 1 photo.';

  @override
  String get productUploaded => 'Produit publié ✔';

  @override
  String get uploadFailed => 'Échec de l’envoi';

  @override
  String get listingLimitReached => 'Limite d’annonces atteinte';

  @override
  String get freeLimitReached => 'Le plan gratuit permet seulement';

  @override
  String get proLimitReached => 'Vous avez atteint votre limite Pro';

  @override
  String get upgradeToPro => 'Passer à Pro';

  @override
  String get upgradeNotAddedYet =>
      'L’écran d’abonnement n’est pas encore ajouté (V1).';

  @override
  String get upgrade => 'Passer au Pro';

  @override
  String get ok => 'OK';

  @override
  String get addUpTo8Photos => 'Ajoutez jusqu’à 8 photos';

  @override
  String get coverPhotoTip =>
      'Astuce : la première photo devient la couverture.';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get add => 'Ajouter';

  @override
  String get productDetailsTitle => 'Détails du produit';

  @override
  String get failedToLoadProduct => 'Impossible de charger le produit';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String get soldUnavailable => 'VENDU • INDISPONIBLE';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get sellerTitle => 'Vendeur';

  @override
  String get markAsSoldTitle => 'Marquer comme vendu ?';

  @override
  String get markAsSoldBody =>
      'Cela va désactiver le chat et marquer ce produit comme vendu.';

  @override
  String get loadingSeller => 'Chargement du vendeur...';

  @override
  String get sellerFallback => 'Vendeur';

  @override
  String get tapToViewProfile => 'Appuyez pour voir le profil';

  @override
  String get sellerProfileTitle => 'Profil du vendeur';

  @override
  String get sellerNotFound => 'Vendeur introuvable';

  @override
  String get sellerRatingLabel => 'Note du vendeur';

  @override
  String get listingsTitle => 'Annonces';

  @override
  String get failedToLoadProducts => 'Impossible de charger les produits';

  @override
  String get noProductsFromSeller => 'Aucun produit publié par ce vendeur';

  @override
  String get soldLabel => 'VENDU';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get profilePhotoHint => 'Une photo claire inspire confiance';

  @override
  String get change => 'Modifier';

  @override
  String get remove => 'Supprimer';

  @override
  String get fullName => 'Nom complet';

  @override
  String get bio => 'Bio';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get notLoggedIn => 'Utilisateur non connecté';

  @override
  String get failedToLoadProfile => 'Impossible de charger le profil';

  @override
  String get nameRequired => 'Le nom est obligatoire';

  @override
  String get profileUpdated => 'Profil mis à jour ✔';

  @override
  String updateFailed(Object error) {
    return 'Échec de la mise à jour : $error';
  }

  @override
  String get logoutTitle => 'Se déconnecter ?';

  @override
  String get logoutBody =>
      'Voulez-vous vraiment vous déconnecter de votre compte ?';

  @override
  String get logout => 'Se déconnecter';

  @override
  String logoutFailed(Object error) {
    return 'Échec de la déconnexion : $error';
  }

  @override
  String get noProfileFound => 'Aucun profil trouvé';

  @override
  String get unknownUser => 'Inconnu';

  @override
  String get pro => 'PRO';

  @override
  String get listings => 'Annonces';

  @override
  String get rating => 'Note';

  @override
  String ratingCountLabel(int count) {
    return '($count avis)';
  }

  @override
  String get myListings => 'Mes annonces';

  @override
  String get favorites => 'Favoris';

  @override
  String get settings => 'Paramètres';

  @override
  String get helpSupport => 'Aide & support';

  @override
  String get help => 'Aide';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get call => 'Appeler';

  @override
  String get helpNeedHelpTitle => 'Besoin d’aide ?';

  @override
  String get helpNeedHelpSubtitle =>
      'Contactez-nous directement. Nous répondons rapidement.';

  @override
  String get helpWhatsappMessage =>
      'Bonjour le support Ka-Loumo, j’ai besoin d’aide.';

  @override
  String get helpEmailSubject => 'Support Ka-Loumo';

  @override
  String get helpEmailBody =>
      'Bonjour,\n\nJ’ai besoin d’aide avec Ka-Loumo.\n\nMerci.';

  @override
  String get helpFooter => 'Ka-Loumo • Guinée 🇬🇳';

  @override
  String get unableToOpenAction => 'Impossible d’ouvrir cette action';

  @override
  String get checkoutCouldNotStart => 'Impossible de démarrer le paiement.';

  @override
  String get unableToOpenPaymentPage =>
      'Impossible d’ouvrir la page de paiement.';

  @override
  String get paymentError => 'Erreur de paiement';

  @override
  String get upgradeToProTitle => 'Passer en Pro ?';

  @override
  String get upgradeToProBody =>
      'Vous serez redirigé vers Stripe pour terminer le paiement.\n\nAprès le paiement, le mode Pro s’active automatiquement.';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get youAreOnPro => 'Vous êtes en Pro';

  @override
  String get youAreOnFree => 'Vous êtes en Gratuit';

  @override
  String activeListingsLabel(int active, int limit) {
    return 'Annonces actives : $active / $limit';
  }

  @override
  String get planFreeTitle => 'Gratuit';

  @override
  String get planFreePrice => '0 GNF';

  @override
  String get planFreeBadge => 'Par défaut';

  @override
  String get planFreeFeature1 => 'Jusqu’à 3 annonces actives';

  @override
  String get planFreeFeature2 => 'Chat avec acheteurs/vendeurs';

  @override
  String get planFreeFeature3 => 'Profil de base';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProPrice => 'Stripe';

  @override
  String get planProBadge => 'Recommandé';

  @override
  String get planProFeature1 => 'Jusqu’à 50 annonces actives';

  @override
  String get planProFeature2 => 'Plus de visibilité (bientôt)';

  @override
  String get planProFeature3 => 'Badge vendeur (bientôt)';

  @override
  String get alreadyPro => 'Déjà Pro ✅';

  @override
  String get upgradeToProButton => 'Passer en Pro';

  @override
  String get proAutoActivatesHint =>
      'Le mode Pro s’active automatiquement après confirmation Stripe.';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get failedToLoadFavorites => 'Impossible de charger les favoris.';

  @override
  String get favoritesEmptyTitle => 'Aucun favori pour le moment';

  @override
  String get favoritesEmptySubtitle =>
      'Commence à ajouter les articles que tu aimes ❤️';

  @override
  String get myListingsTitle => 'Mes annonces';

  @override
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get failedToLoadListings => 'Impossible de charger les annonces.';

  @override
  String get noListingsYet => 'Aucune annonce pour le moment';

  @override
  String get listingsEmptySubtitle => 'Tes produits apparaîtront ici';

  @override
  String get deleteProductTitle => 'Supprimer le produit';

  @override
  String get deleteProductBody =>
      'Voulez-vous vraiment supprimer cette annonce ? Cette action est irréversible.';

  @override
  String get listingDeletedSuccess => 'Annonce supprimée ✅';

  @override
  String get deleteFailed => 'Échec de la suppression';

  @override
  String get edit => 'Modifier';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageSubtitle => 'Changer la langue de l’application';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsChangePasswordSubtitle =>
      'Mettre à jour votre mot de passe';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyPolicySubtitle => 'Lire notre politique';

  @override
  String get termsTitle => 'Conditions d’utilisation';

  @override
  String get termsSubtitle => 'Lire les conditions d’utilisation';

  @override
  String get unableToOpenLink => 'Impossible d’ouvrir le lien';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get showPasswords => 'Afficher les mots de passe';

  @override
  String get fillAllFields => 'Remplissez tous les champs';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordMin6 =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour ✅';

  @override
  String get noEmailPasswordLogin =>
      'Ce compte n’utilise pas la connexion email/mot de passe.';

  @override
  String get failed => 'Échec';

  @override
  String get error => 'Erreur';

  @override
  String get update => 'Mettre à jour';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get save => 'Enregistrer';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get catHome => 'Maison';

  @override
  String get catOthers => 'Autres';

  @override
  String get newCondition => 'Neuf';

  @override
  String get used => 'Occasion';

  @override
  String get msgLoginRequired => 'Veuillez vous connecter pour continuer.';

  @override
  String get paymentSuccessTitle => 'Paiement réussi';

  @override
  String get paymentSuccessBody =>
      'Votre mise à niveau a réussi. Les fonctionnalités Pro seront activées sous peu.';

  @override
  String get paymentCanceledTitle => 'Paiement annulé';

  @override
  String get paymentCanceledBody =>
      'Le processus de mise à niveau a été annulé. Aucun paiement n’a été effectué.';

  @override
  String get done => 'Terminé';

  @override
  String get back => 'Retour';
}
