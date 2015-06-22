xquery version "3.0";
declare namespace  lina="http://lina.digital";

import module namespace console="http://exist-db.org/xquery/console";
import module namespace json="http://lina.digital/json" at "/db/apps/lina/json.xqm";

(: Asuming you have the module for the preparation of json files and hte recent lina.xml 
 : files in a folder like described by variable $col, you can prepare ALL markdown and
 : data files needed for the incredible dlina website with the help of this XQuery!
 : The first sequence ($dlina-ids) is to prevent the IDs ($num) created when first starting this 
 : program. So we can be sure, that the links are stable. We needed to hardcode them once.
 : For the lazy ones: Just add one of the following tasks in lower case to the sequence $what
 : 
 : TEST: test run with a single lina file
 : JSON: creates JSON
 : LINA: creates the syntaxhighlighted XML
 : ENTRY: creates the entry point
 : MATRIX: ok, yo got it
 : NETWORK: again.
 :   :)


let $what := ('test','json')

let $dlina-ids := if ($what = 'test') then ("Lessing, Gotthold Ephraim: Emilia Galotti")
else
("Goethe, Johann Wolfgang von: Iphigenie auf Tauris",
"Hafner, Philipp: Mgera, die frchterliche Hexe oder Das bezauberte Schlo des Herrn von Einhorn",
"Wedekind, Frank: Der Kammersnger",
"Immermann, Karl: Merlin",
"Hafner, Philipp: Der Furchtsame",
"Gutzkow, Karl: Richard Savage oder Der Sohn einer Mutter",
"Mylius, Christlob: Die Schferinsel",
"Schiller, Friedrich: Die Ruber",
"Gotter, Friedrich Wilhelm: Der Dorfjahrmarkt",
"Grillparzer, Franz: Des Meeres und der Liebe Wellen",
"Ludwig, Otto: Der Erbfrster",
"Hofmannsthal, Hugo von: Die Frau ohne Schatten",
"Klopstock, Friedrich Gottlieb: Der Tod Adams",
"Weidmann, Paul: Johann Faust",
"Iffland, August Wilhelm: Das Erbtheil des Vaters",
"Hebbel, Friedrich: Der gehrnte Siegfried",
"Schnitzler, Arthur: Der einsame Weg",
"Mal, Karl: Der alte BrgerCapitain oder Die Entfhrung",
"Gutzkow, Karl: Das Urbild des Tartffe",
"Mhsam, Erich: Judas Ein Arbeiterdrama",
"Kaiser, Friedrich: Stadt und Land oder Der Viehhndler aus Obersterreich",
"Schnitzler, Arthur: Zum grossen Wurstel",
"Wedekind, Frank: Hidalla oder Sein und Haben",
"Lautensack, Heinrich: Die Pfarrhauskomdie",
"Schiller, Friedrich: Wallensteins Lager",
"Gehe, Eduard Heinrich: Jessonda",
"Bauernfeld, Eduard von: Brgerlich und Romantisch",
"Nestroy, Johann: Zu ebener Erde und erster Stock oder Die Launen des Glckes",
"Heiseler, Henry von: Die Kinder Godunfs",
"Scheerbart, Paul: Der alte Petrus, oder Im Himmel spukt es auch",
"Lessing, Gotthold Ephraim: Damon, oder die wahre Freundschaft",
"Gerstenberg, Heinrich Wilhelm von: Ugolino",
"Stephanie, Johann Gottlieb der Jngere: Der Schauspieldirektor",
"Scheerbart, Paul: Es lebe Europa",
"Benedix, Julius Roderich: Die Hochzeitsreise",
"Mosenthal, Salomon Hermann von: Die Knigin von Saba",
"Thoma, Ludwig: Die Medaille",
"Goethe, Johann Wolfgang von: Die natrliche Tochter",
"Anzengruber, Ludwig: Heimgfunden",
"Wedekind, Frank: Frhlings Erwachen",
"Alberti, Konrad: Im Suff",
"Gutzkow, Karl: Uriel Acosta",
"Hebbel, Friedrich: Agnes Bernauer",
"Mal, Karl: Jungfern Kchinnen",
"Gutzkow, Karl: Zopf und Schwert",
"Essig, Hermann: berteufel",
"Heyse, Paul: Colberg",
"Brandes, Johann Christian: Ariadne auf Naxos",
"Kleist, Heinrich von: Die Familie Schroffenstein",
"Leisewitz, Johann Anton: Julius von Tarent",
"Holz, Arno: Sozialaristokraten",
"Ertler, Bruno: Das Spiel von Doktor Faust",
"Klinger, Friedrich Maximilian: Sturm und Drang",
"Anzengruber, Ludwig: Der Meineidbauer",
"Devrient, Philipp Eduard: Hans Heiling",
"Thoma, Ludwig: Moral",
"Kotzebue, August von: Die Indianer in England",
"Schiller, Friedrich: Wallensteins Tod",
"Hauptmann, Carl: Die armseligen Besenbinder",
"Hauptmann, Carl: Frau Nadja Bielew",
"Gotter, Friedrich Wilhelm: Die Geisterinsel",
"Nestroy, Johann: Der bse Geist Lumpazivagabundus oder Das liederliche Kleeblatt",
"Laube, Heinrich: Gottsched und Gellert",
"Vischer, Friedrich Theodor: Faust",
"Bleibtreu, Karl: Weltgericht",
"Sturz, Helfrich Peter: Julie",
"Lachmann, Hedwig: Salome",
"Cronegk, Johann Friedrich von: Der Mitrauische",
"Laufs, Carl: Pension Schller",
"Klabund: Der Kreidekreis",
"Wedekind, Frank: Tod und Teufel",
"Schink, Johann Friedrich: Der neue Doktor Faust",
"Thoma, Ludwig: Magdalena",
"Platen, August von: Die verhngnisvolle Gabel",
"Ball, Hugo: Die Nase des Michelangelo",
"Raimund, Ferdinand: Der Diamant des Geisterknigs",
"DrosteHlshoff, Annette von: Perdu oder Dichter, Verleger und Blaustrmpfe",
"Kleist, Heinrich von: Die Hermannsschlacht",
"Hofmannsthal, Hugo von: Der Tor und der Tod",
"Schnitzler, Arthur: Liebelei",
"Rosenow, Emil: Kater Lampe",
"Goethe, Johann Wolfgang von: Torquato Tasso",
"Nestroy, Johann: Der Talisman",
"Panizza, Oskar: Das Liebeskonzil",
"Bchner, Georg: Dantons Tod",
"Schiller, Friedrich: Die Piccolomini",
"Lessing, Gotthold Ephraim: Mi Sara Sampson",
"Lessing, Gotthold Ephraim: Emilia Galotti",
"Schnitzler, Arthur: Anatol",
"Beer, Michael: Struensee",
"Uhland, Ludwig: Ernst Herzog von Schwaben",
"BirchPfeiffer, Charlotte: Vatersorgen",
"Kaiser, Friedrich: Die Schule des Armen oder Zwei Millionen",
"Lortzing, Albert Gustav: Zar und Zimmermann",
"Sonnleithner, Joseph Ferdinand von: Fidelio",
"Schiller, Friedrich: Kabale und Liebe",
"Scheerbart, Paul: Die Wurzeln der Wohlhabenheit",
"Thoma, Ludwig: Erster Klasse",
"Hartleben, Otto Erich: Hanna Jagert",
"Sudermann, Hermann: Heimat",
"Hebbel, Friedrich: Herodes und Mariamne",
"Hofmannsthal, Hugo von: Der Abenteurer und die Sngerin oder Die Geschenke des Lebens",
"Klinger, Friedrich Maximilian: Die neue Arria",
"Hauptmann, Carl: Ephraims Breite",
"Wagner, Richard: Siegfried",
"Goethe, Johann Wolfgang von: Der Brgergeneral",
"Sudermann, Hermann: Die Ehre",
"Grillparzer, Franz: Sappho",
"Hofmannsthal, Hugo von: Der Rosenkavalier",
"Klingemann, August: Faust",
"Hensler, Karl Friedrich: Die Teufelsmhle am Wienerberg",
"Scheerbart, Paul: Okurirasna",
"Halm, Friedrich: Der Sohn der Wildnis",
"Hartleben, Otto Erich: Rosenmontag",
"Hofmannsthal, Hugo von: Alkestis",
"Raimund, Ferdinand: Der Barometermacher auf der Zauberinsel",
"Nestroy, Johann: Der Unbedeutende",
"Eichendorff, Joseph von: Die Freier",
"Meisl, Karl: Der lustige Fritz oder Schlafe, Trume, stehe auf, kleide dich an und bessre dich",
"Anzengruber, Ludwig: Der Gwissenswurm",
"Grillparzer, Franz: Ein Bruderzwist in Habsburg",
"Neuber, Friederike Caroline: Das Schferfest oder Die Herbstfreude",
"Goethe, Johann Wolfgang von: Gtz von Berlichingen mit der eisernen Hand",
"Gellert, Christian Frchtegott: Die Betschwester",
"Gnderode, Karoline von: Nikator",
"Goethe, Johann Wolfgang von: Stella",
"Hofmannsthal, Hugo von: Der Tod des Tizian",
"Berg, O F: Berlin, wie es weint und lacht",
"Anzengruber, Ludwig: Das vierte Gebot",
"Goethe, Johann Wolfgang von: Der Triumph der Empfindsamkeit",
"Nestroy, Johann: Freiheit in Krhwinkel",
"Rubiner, Ludwig: Die Gewaltlosen",
"Stephanie, Johann Gottlieb der Jngere: Die Liebe im Narrenhause",
"Bauernfeld, Eduard von: Grojhrig",
"Wedekind, Frank: Fritz Schwigerling oder Der Liebestrank",
"Grillparzer, Franz: Weh dem, der lgt",
"Wilbrandt, Adolf von: Der Meister von Palmyra",
"Scheerbart, Paul: Lachende Gespenster",
"Reinick, Robert: Genoveva",
"Wedekind, Frank: Erdgeist",
"Scheerbart, Paul: Die Puppe und die Dauerwurst",
"Kotzebue, August von: Menschenha und Reue",
"Platen, August von: Der romantische dipus",
"Kurz, Joseph von:: Prinzessin Pumphia",
"Busoni, Ferruccio: Turandot",
"Wedekind, Frank: Musik",
"Lortzing, Albert Gustav: Der Waffenschmied",
"Wieland, Christoph Martin: Klementina von Porretta",
"Sorge, Reinhard Johannes: Der Sieg des Christos",
"Schnitzler, Arthur: Komtesse Mizzi oder Der Familientag",
"BirchPfeiffer, Charlotte: Die Walpurgisnacht",
"Kleist, Heinrich von: Penthesilea",
"Scheerbart, Paul: Herr Kammerdiener Kneetschke",
"Schober, Franz von: Alfonso und Estrella",
"Lenz, Jakob Michael Reinhold: Die Freunde machen den Philosophen",
"Iffland, August Wilhelm: Die Jger",
"Goethe, Johann Wolfgang von: Clavigo",
"Grabbe, Christian Dietrich: Herzog Theodor von Gothland",
"Hofmannsthal, Hugo von: Jedermann",
"Hebbel, Friedrich: Kriemhilds Rache",
"Hofmannsthal, Hugo von: Das Bergwerk zu Falun",
"Roeber, Friedrich: Knig Manfred",
"Wildgans, Anton: In Ewigkeit Amen",
"Schlegel, Friedrich: Alarkos",
"Blumenthal, Oskar: Im weien Rl",
"Wagner, Richard: Tristan und Isolde",
"Immermann, Karl: Eudoxia",
"Stavenhagen, Fritz: Mudder Mews",
"Wette, Adelheid: Hnsel und Gretel",
"Grillparzer, Franz: Die Jdin von Toledo",
"Alberti, Konrad: Brot",
"Wildenbruch, Ernst von: Die Quitzows",
"Krger, Johann Christian: Die Geistlichen auf dem Lande",
"Holz, Arno: Sonnenfinsternis",
"Wagner, Richard: Lohengrin",
"Schnitzler, Arthur: Anatols Grenwahn",
"Brandes, Johann Christian: Ino",
"Goethe, Johann Wolfgang von: Die Mitschuldigen",
"Hebbel, Friedrich: Der Diamant",
"Kaltneker, Hans: Die Opferung",
"Scheerbart, Paul: Der Herr vom Jenseits",
"Scheerbart, Paul: Der vornehme Ruberhauptmann",
"Scheerbart, Paul: Das dumme Luder",
"Raimund, Ferdinand: Die unheilbringende Zauberkrone oder Knig ohne Reich, Held ohne Mut, Schnheit ohne Jugend",
"Bauernfeld, Eduard von: Industrie und Herz",
"Weie, Christian Felix: Die Jagd",
"Wildgans, Anton: Armut",
"Kotzebue, August von: Der Hyperboreische Esel, oder Die heutige Bildung",
"GemmingenHornberg, Otto Heinrich von: Der deutsche Hausvater oder die Familie",
"Klinger, Friedrich Maximilian: Die Zwillinge",
"Wedekind, Frank: Knig Nicolo oder So ist das Leben",
"Quistorp, Theodor Johann: Der Hypochondrist",
"Auenbrugger, Johann Leopold von: Der Rauchfangkehrer oder Die unentbehrlichen Verrther ihrer Herrschaften aus Eigennutz",
"Lessing, Gotthold Ephraim: Philotas",
"Arnim, Ludwig Achim von: Jerusalem",
"Heiseler, Henry von: Peter und Alexj",
"LArronge, Adolph: Mein Leopold",
"Goethe, Johann Wolfgang von: Der Grokophta",
"Bodorf, Hermann: Bahnmeister Dood",
"Nestroy, Johann: Das Mdl aus der Vorstadt oder Ehrlich whrt am lngsten",
"Goethe, Johann Wolfgang von: Faust Der Tragdie zweiter Teil",
"Braun von Braunthal, Karl Johann: Das Nachtlager von Granada",
"Fock, Gorch: Cili Cohrs",
"Braun von Braunthal, Karl Johann: Faust",
"Schnitzler, Arthur: Der tapfere Cassian",
"Nestroy, Johann: Einen Jux will er sich machen",
"Thoma, Ludwig: Lottchens Geburtstag",
"Kleist, Heinrich von: Das Kthchen von Heilbronn oder die Feuerprobe",
"Grabbe, Christian Dietrich: Don Juan und Faust",
"Hofmannsthal, Hugo von: Arabella",
"Ayrenhoff, Cornelius Hermann von: Der Postzug oder die noblen Passionen",
"Fouqu, Friedrich de la Motte: Der Held des Nordens",
"Weienthurn, Johanna von: Die Schwestern St Janvier",
"Rilke, Rainer Maria: Ohne Gegenwart",
"Pfeil, Johann Gottlob Benjamin: Lucie Woodvil",
"Buerle, Adolf: Doktor Fausts Mantel",
"Schiller, Friedrich: Don Carlos, Infant von Spanien",
"Schink, Johann Friedrich: Hanswurst von Salzburg mit dem hlzernen Gat",
"Bunge, Rudolf: Der Trompeter von Skkingen",
"Gottsched, Luise Adelgunde Victorie: Das Testament",
"May, Karl: Babel und Bibel",
"Lessing, Gotthold Ephraim: Die Juden",
"Holz, Arno: Die Familie Selicke",
"Goethe, Johann Wolfgang von: Die Laune des Verliebten",
"Kotzebue, August von: Die deutschen Kleinstdter",
"Neuber, Friederike Caroline: Die von der Weisheit wider die Unwissenheit beschtzte Schauspielkunst",
"Schiller, Friedrich: Die Jungfrau von Orleans",
"Simrock, Karl: Doctor Johannes Faust",
"Mhsam, Erich: Staatsrson",
"Neuber, Friederike Caroline: Die Verehrung der Vollkommenheit durch die gebesserten deutschen Schauspiele",
"Scheerbart, Paul: Rbezahl",
"Schnitzler, Arthur: Reigen",
"Freytag, Gustav: Graf Waldemar",
"Schlegel, August Wilhelm: Jon",
"Iffland, August Wilhelm: Verbrechen aus Ehrsucht",
"Dehmel, Richard Fedor Leopold: Die Menschenfreunde",
"Hofmannsthal, Hugo von: Die Frau im Fenster",
"Hebbel, Friedrich: Gyges und sein Ring",
"Hauptmann, Carl: Der Antiquar",
"Wildenbruch, Ernst von: Die Haubenlerche",
"Raimund, Ferdinand: Der Verschwender",
"Bernard, Josef Karl: Faust",
"Goethe, Johann Wolfgang: Faust Der Tragdie erster Teil",
"Gottsched, Johann Christoph: Der sterbende Cato",
"Wagner, Richard: Der fliegende Hollnder",
"Gotter, Friedrich Wilhelm: Medea",
"BirchPfeiffer, Charlotte: PfefferRsel oder Die Frankfurter Messe im Jahre 1297",
"Schlaf, Johannes: Meister Oelze",
"Lessing, Gotthold Ephraim: Der Schatz",
"Scheerbart, Paul: Der Wetterfrst",
"Rosenow, Emil: Die im Schatten leben",
"Gottsched, Johann Christoph: Atalanta oder die bezwungene Sprdigkeit",
"Hebbel, Friedrich: Demetrius",
"Laube, Heinrich: Monaldeschi",
"Eichendorff, Joseph von: Der letzte Held von Marienburg",
"Schikaneder, Johann Emanuel: Die Zauberflte",
"Weidmann, Paul: Der Dorfbarbier",
"Vo, Julius von: Faust",
"Tieck, Ludwig: Prinz Zerbino oder die Reise nach dem guten Geschmack",
"Leisewitz, Johann Anton: Die Pfandung",
"Mllner, Adolph: Knig Yngurd",
"Engel, Johann Jakob: Eid und Pflicht",
"Lautensack, Heinrich: Medusa",
"Wagner, Heinrich Leopold: Die Reue nach der That",
"Hofmannsthal, Hugo von: Das Salzburger groe Welttheater",
"Heyse, Paul: Don Juans Ende",
"Hofmannsthal, Hugo von: Ariadne auf Naxos",
"BirchPfeiffer, Charlotte: In der Heimath",
"Kotzebue, August von: Der Wildschtz oder Die Stimme der Natur",
"Arnim, Ludwig Achim von: Marino Caboga",
"Schnthan, Franz und Paul von: Der Raub der Sabinerinnen",
"Lessing, Gotthold Ephraim: Der junge Gelehrte",
"Devrient, Philipp Eduard: Die Gunst des Augenblicks",
"Tieck, Ludwig: Ritter Blaubart",
"Zschokke, Heinrich: Abellino",
"Essig, Hermann: Der Frauenmut",
"Schnitzler, Arthur: Das weite Land",
"Avenarius, Ferdinand: Faust",
"Uhland, Ludwig: Ludwig der Bayer",
"Prutz, Robert Eduard: Die politische Wochenstube",
"Kotzebue, August von: Die beiden Klingsberg",
"Ayrenhoff, Cornelius Hermann von: Virginia oder das abgeschaffte Decemvirat",
"Brawe, Joachim Wilhelm von: Der Freigeist",
"Heine, Heinrich: Almansor",
"Tieck, Ludwig: Der gestiefelte Kater",
"Grillparzer, Franz: Knig Ottokars Glck und Ende",
"Lassalle, Ferdinand: Franz von Sickingen",
"Hauptmann, Carl: Im goldenen TempelBuche verzeichnet",
"Holtei, Karl von: Ein Trauerspiel in Berlin",
"Kobell, Franz von: Der Roaga",
"Weie, Christian Felix: Atreus und Thyest",
"Schnitzer, Ignaz: Der Zigeunerbaron",
"Gnderode, Karoline von: Udohla",
"Gessner, Salomon: Evander und Alcimna",
"Wohlbrck, Wilhelm August: Der Vampyr",
"Hebbel, Friedrich: Trauerspiel in Sizilien",
"Scheerbart, Paul: Das Gift",
"Raimund, Ferdinand: Das Mdchen aus der Feenwelt oder Der Bauer als Millionr",
"Dehmel, Richard Fedor Leopold: Michel Michael",
"Hofmannsthal, Hugo von: dipus und die Sphinx",
"Arnim, Ludwig Achim von: Halle",
"Schfer, Wilhelm: Faustine, der weibliche Faust",
"Iffland, August Wilhelm: Der Spieler",
"Anzengruber, Ludwig: Die Kreuzelschreiber",
"Nestroy, Johann: Eulenspiegel oder Schabernack ber Schabernack",
"Schnitzler, Arthur: Der Puppenspieler",
"Riese, Friedrich Wilhelm: Martha oder Der Markt zu Richmond",
"Raimund, Ferdinand: Der Alpenknig und der Menschenfeind",
"Hebbel, Friedrich: Maria Magdalene",
"Scheerbart, Paul: Die Urgrossmutter",
"Schiller, Friedrich: Maria Stuart",
"Immermann, Karl: Andreas Hofer, der Sandwirt von Passeyer",
"Tieck, Ludwig: Die verkehrte Welt",
"Benkowitz, Karl Friedrich: Die Jubelfeier der Hlle, oder Faust der jngere",
"Moser, Gustav von: Krieg oder Frieden",
"Meisl, Karl: Orpheus und Euridice So geht es im Olymp zu",
"Wagner, Richard: Das Rheingold",
"Cornelius, Peter: Der Barbier von Bagdad",
"Wagner, Richard: Gtterdmmerung",
"Krger, Johann Christian: Die Candidaten oder Die Mittel zu einem Amte zu gelangen",
"Neuber, Friederike Caroline: Ein Deutsches Vorspiel",
"Bleibtreu, Karl: Ein Faust der That",
"Wedekind, Frank: Franziska",
"Hebbel, Friedrich: Judith",
"Hebbel, Friedrich: Der Rubin",
"Gellert, Christian Frchtegott: Die zrtlichen Schwestern",
"Hebbel, Friedrich: Genoveva",
"Schlegel, Johann Elias: Die stumme Schnheit",
"Haffner, Carl: Die Fledermaus",
"Klemm, Christian Gottlob: Der auf den Parnass versetzte grne Hut",
"Holtei, Karl von: Die Kalkbrenner",
"Scheerbart, Paul: Der Schornsteinfeger",
"Widmann, Joseph Viktor: Der Widerspenstigen Zhmung",
"Mosenthal, Salomon Hermann von: Die lustigen Weiber von Windsor",
"Eichendorff, Joseph von: Das Incognito oder Die mehreren Knige oder Alt und Neu",
"Schnitzler, Arthur: Der grne Kakadu",
"Anzengruber, Ludwig: Der Pfarrer von Kirchfeld",
"Lenz, Jakob Michael Reinhold: Der Hofmeister oder Vorteile der Privaterziehung",
"Bretzner, Christoph Friedrich: Belmont und Constanze oder Die Entfhrung aus dem Serail",
"Weienthurn, Johanna von: Das Manuscript",
"Nestroy, Johann: Das Haus der Temperamente",
"Schlegel, Johann Elias: Der Triumph der guten Frauen",
"Schnitzler, Arthur: Professor Bernhardi",
"Stephanie, Johann Gottlieb der Jngere: Doktor und Apotheker",
"Klopstock, Friedrich Gottlieb: Hermanns Schlacht",
"Krner, Theodor: Zriny",
"Borkenstein, Hinrich: Der Bookesbeutel",
"Gleich, Joseph Alois: Der Eheteufel auf Reisen",
"Wagner, Richard: Die Walkre",
"Hartleben, Otto Erich: Die sittliche Forderung",
"Ruederer, Josef: Die Fahnenweihe",
"Dovsky, Beatrice: Mona Lisa",
"Niebergall, Ernst Elias: Datterich",
"Benedix, Julius Roderich: Die Lgnerin",
"Buerle, Adolf: Die Brger in Wien",
"Goethe, Johann Wolfgang von: Proserpina",
"Lessing, Gotthold Ephraim: Minna von Barnhelm oder Das Soldatenglck",
"Grillparzer, Franz: Der Traum ein Leben",
"Hippel, Theodor Gottlieb von: Der Mann nach der Uhr, oder der ordentliche Mann",
"Mllner, Adolph: Die Schuld",
"Thoma, Ludwig: Die Lokalbahn",
"Kleist, Heinrich von: Prinz Friedrich von Homburg",
"Kleist, Heinrich von: Der zerbrochene Krug",
"Hofmannsthal, Hugo von: Der Schwierige",
"Freytag, Gustav: Die Journalisten",
"Nestroy, Johann: Der Zerrissene",
"Ertler, Bruno: Belian und Marpalye",
"Panizza, Oskar: Nero",
"Lessing, Gotthold Ephraim: Nathan der Weise",
"Scheerbart, Paul: Das Mirakel",
"Bchner, Georg: Leonce und Lena",
"Grillparzer, Franz: Ein treuer Diener seines Herrn",
"Wieland, Christoph Martin: Alceste",
"Lenz, Jakob Michael Reinhold: Die Soldaten",
"Hofmannsthal, Hugo von: Elektra",
"Ganghofer, Ludwig: Der Herrgottschnitzer von Ammergau",
"Wedekind, Frank: Die Zensur",
"Grabbe, Christian Dietrich: Napoleon oder Die hundert Tage",
"Lessing, Gotthold Ephraim: Der Freigeist",
"Grabbe, Christian Dietrich: Scherz, Satire, Ironie und tiefere Bedeutung",
"Stephanie, Johann Gottlieb der Jngere: Die Entfhrung aus dem Serail",
"Schrder, Friedrich Ludwig: Der Vetter in Lissabon",
"Goethe, Johann Wolfgang von: Erwin und Elmire",
"Brentano, Clemens: Die Grndung Prags",
"Hauptmann, Carl: Tobias Buntschuh",
"Hofmannsthal, Hugo von: Der Unbestechliche",
"Hofmannsthal, Hugo von: Der Turm",
"Goethe, Johann Wolfgang von: Satyros oder Der vergtterte Waldteufel",
"Laube, Heinrich: Struensee",
"Holz, Arno: Ignorabimus",
"Lessing, Gotthold Ephraim: Der Misogyn",
"Hebbel, Friedrich: Siegfrieds Tod",
"Grabbe, Christian Dietrich: Hannibal",
"Weienthurn, Johanna von: Welche ist die Braut",
"Gottsched, Luise Adelgunde Victorie: Der Witzling",
"Wagner, Heinrich Leopold: Die Kindermrderin",
"Schlegel, Johann Elias: Der geschftige Miggnger",
"Gerhuser, Emil: Der Moloch",
"Holz, Arno: Traumulus",
"Lenz, Jakob Michael Reinhold: Der neue Menoza oder Geschichte des cumbanischen Prinzen Tandi",
"Lessing, Gotthold Ephraim: Die alte Jungfer",
"LArronge, Adolph: Hasemanns Tchter",
"Kaltneker, Hans: Das Bergwerk",
"Trring, Josef August von: Agnes Bernauerin",
"Kind, Johann Friedrich: Der Freischtz",
"Hauptmann, Carl: Gaukler, Tod und Juwelier",
"Arnim, Ludwig Achim von: Das Loch oder Das Wiedergefundene Paradies",
"Brentano, Clemens: Ponce de Leon",
"Goethe, Johann Wolfgang von: Gtter, Helden und Wieland",
"Scheerbart, Paul: Der Regierungswechsel",
"BirchPfeiffer, Charlotte: Johannes Gutenberg",
"Werner, Zacharias: Der vierundzwanzigste Februar",
"Wagner, Richard: Parsifal",
"Widmann, Joseph Viktor: MaikferKomdie",
"Wagner, Richard: Tannhuser und Der Sngerkrieg auf Wartburg",
"Raimund, Ferdinand: Die gefesselte Phantasie",
"Schlegel, Johann Elias: Canut",
"Sorge, Reinhard Johannes: Odysseus",
"Bodorf, Hermann: De rode nnerrock",
"Ertler, Bruno: Anna Iwanowna",
"Scheerbart, Paul: Die lustigen Ruber",
"Wagner, Richard: Die Meistersinger von Nrnberg",
"Lenz, Jakob Michael Reinhold: Der Englnder",
"Scheerbart, Paul: Der fanatische Brgermeister",
"Wedekind, Frank: Der Marquis von Keith",
"Wagner, Heinrich Leopold: Voltaire am Abend seiner Apotheose",
"Raimund, Ferdinand: Moisasurs Zauberfluch",
"Wildgans, Anton: Dies irae",
"Scheerbart, Paul: Die Welt geht unter",
"Ludwig, Otto: Die Makkaber",
"Raupach, Ernst: Kritik und Antikritik",
"Lautensack, Heinrich: Hahnenkampf",
"Chzy, Helmina von: Euryanthe",
"Iffland, August Wilhelm: Figaro in Deutschland",
"Mller, Friedrich Maler Mller: Golo und Genovefa",
"Wedekind, Frank: Die Bchse der Pandora",
"Kleist, Heinrich von: Amphitryon",
"Kupelwieser, Josef: Fierrabras",
"Wildenbruch, Ernst von: Die Karolinger",
"Gnderode, Karoline von: Magie und Schicksal",
"Nestroy, Johann: Judith und Holofernes",
"Goethe, Johann Wolfgang von: Egmont",
"Klinger, Friedrich Maximilian: Simsone Grisaldo",
"Grillparzer, Franz: Die Ahnfrau",
"Wieland, Christoph Martin: Lady Johanna Gray oder Der Triumf der Religion",
"Heine, Heinrich: William Ratcliff",
"Leisewitz, Johann Anton: Der Besuch um Mitternacht",
"Hauptmann, Carl: Musik",
"Bodmer, Johann Jacob: Odoardo Galotti, Vater der Emilia",
"Soden, Julius von: Doktor Faust",
"Schiller, Friedrich: Die Verschwrung des Fiesco zu Genua",
"Schiller, Friedrich: Wilhelm Tell",
"Laube, Heinrich: Die Karlsschler",
"Mosenthal, Salomon Hermann von: Das goldene Kreuz",
"Beer, Michael: Der Paria",
"Weienthurn, Johanna von: Johann, Herzog von Finnland",
"Moser, Gustav von: Das Stiftungsfest",
"Goethe, Johann Wolfgang von: Des Epimenides Erwachen",
"Dulk, Albert: Die Wnde",
"Wilbrandt, Adolf von: Gracchus der Volkstribun",
"Sudermann, Hermann: Der Bettler von Syrakus",
"Gottsched, Luise Adelgunde Victorie: Die Pietisterey im FischbeinRocke",
"Immermann, Karl: Die Bojaren",
"Weienthurn, Johanna von: Welcher ist der Brutigam",
"Immermann, Karl: Das Gericht von St Petersburg")

(:TEST with a single tiem :)
(:  let $dlina-ids := ("Lessing, Gotthold Ephraim: Emilia Galotti"):)

(: CLEAN UP! :)
let $cleanup := (
    for $task in $what
    return
    if ($task = 'json') then (xmldb:remove('/db/temp/json'),xmldb:create-collection('/db/temp', "json" ))
    else if ($task = 'lina') then (xmldb:remove('/db/temp/lina'),xmldb:create-collection('/db/temp', "lina" ))
    else if ($task = 'matrix') then (xmldb:remove('/db/temp/matrix'),xmldb:create-collection('/db/temp', "matrix" ))
    else if ($task = 'entry') then (xmldb:remove('/db/temp/entry'),xmldb:create-collection('/db/temp', "entry" ))
    else if ($task = 'network') then(xmldb:remove('/db/temp/network'),xmldb:create-collection('/db/temp', "network" ))
    else if ($task = 'amount') then (xmldb:remove('/db/temp/amount'),xmldb:create-collection('/db/temp', "amount") )
    else 'nothing to clean')



let $col := collection('/db/data/tmp/lina')
let $pattern := '[^a-zA-Z0-9:,\s]'

return
for $id in $dlina-ids
    let $console := console:log(index-of($dlina-ids, $id))
    return
        for $lina in $col/lina:play//lina:header[concat(lina:author/replace(., $pattern, ''), ': ', lina:title/replace(., $pattern, '') ) = $id]

let $date := 
if ($lina//lina:date[@type='print']/@when and $lina//lina:date[@type='premiere']/@when) then min(number($lina//lina:date[@type='print']/@when), number($lina//lina:date[@type='premiere']/@when)) else if (number($lina//lina:date[@type='premiere']/@when)) then $lina//lina:date[@type='premiere']/@when else number($lina//lina:date[@type='print']/@when),
$date := if ($date - 10 gt number($lina//lina:date[@type='written']/@when)) then number($lina//lina:date[@type='written']/@when) else $date
   
let $title := $lina//lina:author[1]/string()|| ': ' ||  $lina//lina:title[last()]/string() || ' (' ||  $date || ')'
let $num := index-of($dlina-ids, $id)

(: lina file with xml source :)

let
$filenamexml := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-lina' || $num || '.md'
let 
$linafilexml :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags:
imagefeature:
mathjax:
chart:
comments: true
featured: false
list: false
---
{% highlight xml %}
'||
serialize(doc( $lina/base-uri() )) ||'
{% endhighlight %}' 

(: THE MATRIX :)
let
$filenamematrix := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-matrix' || $num || '.md',
$linafilematrix :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags: []
imagefeature: 
mathjax: 
chart: 
comments: false
featured: false
list: false
networkdata: ' || $num ||'.json
---
{% include matrix.html %}
'

(: THE NETWORK :)

let
$filenamenetwork := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-network' || $num || '.md',
$linafilenetwork :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags: []
imagefeature: 
mathjax: 
chart: 
comments: false
featured: false
list: false
networkdata: ' || $num ||'.json
---
{% include network.html %}
{% include network-static.html %}
'

(: JSON :)

let
$filenamejson := ($num || '.json'),
$linafilejson:= json:json( doc( $lina/base-uri() ) )

(: ENTRY POINT :)
let
$filenameentry := ( year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-' || $num || '.md' ),
$table := string-join(
    for $value in $lina/lina:* 
        return 
            $value/name() || 
                    (if ($value/attribute::*) 
                    then string-join(for $attr in $value/@* return ('[@'|| name($attr) || '="'|| string($attr) || '"]')) 
                    else '')
                    || '|' || (if (contains($value, 'textgridlab.org')) then '[' || substring-after(substring-before($value, '/data'), 'tgcrud-public/rest/') || '](' || $value/string() || ')' else $value/string()) || '
'),
$linafileentry :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags:
imagefeature: 
mathjax: 
chart: 
comments: true
featured: false
list: true
networkdata: ' || $filenamejson ||'
---
lina.xml data  | value
------------- | -------------
' || $table || '


* [Network (sticky and static)](/network'|| $num ||')
* [Matrix](/matrix' || $num || ')
* [Amounts](/amount' || $num || ')
* [Zwischenformat](/lina'|| $num ||' )
'

(: AMOUNTS :)

let
$filenamebarchart := year-from-date(current-date()) || '-' || month-from-date(current-date()) || '-' || day-from-date(current-date()) || '-' || 'amount' || $num || '.md',
$filenametsv := $num || '.tsv',
$linafilebarchart :=
'---
layout: network
title: "' || $title || '"
author:
description:
headline:
modified:
category:
tags:
imagefeature: 
mathjax: 
chart: 
comments: true
featured: false
list: false
amounttsv: ' || $filenametsv ||'
---
{% include barchart.html %}
'

let $tab := '&#9;' (: tab :),
$linafiletsv :=
('name'||$tab||'acts'||$tab||'words'||$tab||'chars'||$tab||'
'||
string-join(for $c in $lina/parent::lina:play//lina:character
return
    ($c//lina:name/string())[1]||$tab||
    sum($lina/parent::lina:play//lina:amount[parent::lina:sp/@who = $c//lina:alias/concat('#', @xml:id)][@unit='speech_acts']/xs:int(@n)) ||$tab||
    sum($lina/parent::lina:play//lina:amount[parent::lina:sp/@who = $c//lina:alias/concat('#', @xml:id)][@unit='words']/xs:int(@n)) ||$tab||
    sum($lina/parent::lina:play//lina:amount[parent::lina:sp/@who = $c//lina:alias/concat('#', @xml:id)][@unit='chars']/xs:int(@n)) ||$tab||'
' )  
)

return 
for $task in $what
    return
    if ($task = 'json') then xmldb:store('/db/temp/json', $filenamejson, $linafilejson, 'text/plain')
    else if ($task = 'lina') then xmldb:store('/db/temp/lina', $filenamexml, $linafilexml, 'text/plain')
    else if ($task = 'matrix') then xmldb:store('/db/temp/matrix', $filenamematrix, $linafilematrix, 'text/plain')
    else if ($task = 'entry') then xmldb:store('/db/temp/entry', $filenameentry, $linafileentry, 'text/plain')
    else if ($task = 'network') then  xmldb:store('/db/temp/network', $filenamenetwork, $linafilenetwork, 'text/plain')
    else if ($task = 'amount') then ( xmldb:store('/db/temp/amount', $filenamebarchart, $linafilebarchart, 'text/plain'),xmldb:store('/db/temp/amount', $filenametsv, $linafiletsv, 'text/plain') )
    else 'one round for free'
