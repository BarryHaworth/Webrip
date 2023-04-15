# Mobile Wallpapers
# http://mobile.com/
# 
# Sample wallpaper at:
# https://wallpaper.mob.org/image/3d-kosmicheskii_vzriv-yarkii-linii-formi-obem-119333.html
#
# This webcomic does not have a standardised naming convention.
# To copy, it will be necessary to start at the first page 
# and then crawl through the comics page by page to identify 
# the next page, then the story image.
# 
# Update:  Added code to create directories if they do not exist
# and to catch errors when ripping and downloading and continue.
#
# This website does not have a standardised sequence that covers all records.  
# Instead, will selected several start points and follow 1000 links, then add to the total set.

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/mobile"
dir.create(FILE_DIR,showWarnings = FALSE)

# First page of site
# url <- 'https://wallpaper.mob.org/image/3d-kosmicheskii_vzriv-yarkii-linii-formi-obem-119333.html' # First attempt
# url <- 'https://wallpaper.mob.org/image/devushka-muzikant-gitara-naushniki-art-128435.html' # girl
# url <- 'https://wallpaper.mob.org/image/anime-muzhchiny-16994.html' # anime
# url <- 'https://wallpaper.mob.org/image/silueti-para-lyubov-romantika-obyatiya-palmi-temnii-80778.html'  # love
# url <- 'https://wallpaper.mob.org/image/silueti-lyubov-para-romantika-noch-art-106721.html' # romance
# url <- 'https://wallpaper.mob.org/image/lyubov-potselui-dozhd-art-140300.html' # kiss
# url <- 'https://wallpaper.mob.org/image/nature-rastenie-listya-zhilki-temnii-82122.html' # dark
# url <- 'https://wallpaper.mob.org/image/les-volshebstvo-babochki-fentezi-art-67940.html' # fantasy
# url <- 'https://wallpaper.mob.org/image/3d-babochka-listya-krilya-kontrast-128113.html' # 3d
# url <- 'https://wallpaper.mob.org/image/koshki-zhivotnye-7572.html' # cats
# url <- 'https://wallpaper.mob.org/image/leopardy-risunki-zhivotnye-35787.html' # animals
# url <- 'https://wallpaper.mob.org/image/fantasy-gorod-futurizm-sci_fi-budushchee-fantastika-157242.html' #scifi
# url <- 'https://wallpaper.mob.org/image/fentezi-roboty-7002.html' # robots
# url <- 'https://wallpaper.mob.org/image/chelovek-odinoko-odinochestvo-grust-art-150452.html' # ?
# url <- 'https://wallpaper.mob.org/image/space-planeta-zemlya-kosmos-prostranstvo-142960.html' # space
# url <- 'https://wallpaper.mob.org/image/art-kosmicheskii_korabl-skali-landshaft-vnezemnoi-ptitsi-siyanie-avrora-tuman-155723.html' #Spaceship

urls <- c( 'https://wallpaper.mob.org/image/devushka-muzikant-gitara-naushniki-art-128435.html' ,
 'https://wallpaper.mob.org/image/anime-muzhchiny-16994.html' ,
 'https://wallpaper.mob.org/image/silueti-para-lyubov-romantika-obyatiya-palmi-temnii-80778.html'  ,
 'https://wallpaper.mob.org/image/silueti-lyubov-para-romantika-noch-art-106721.html' ,
 'https://wallpaper.mob.org/image/lyubov-potselui-dozhd-art-140300.html' ,
 'https://wallpaper.mob.org/image/nature-rastenie-listya-zhilki-temnii-82122.html' ,
 'https://wallpaper.mob.org/image/les-volshebstvo-babochki-fentezi-art-67940.html' ,
 'https://wallpaper.mob.org/image/3d-babochka-listya-krilya-kontrast-128113.html' ,
 'https://wallpaper.mob.org/image/koshki-zhivotnye-7572.html' ,
 'https://wallpaper.mob.org/image/leopardy-risunki-zhivotnye-35787.html' ,
 'https://wallpaper.mob.org/image/fantasy-gorod-futurizm-sci_fi-budushchee-fantastika-157242.html' ,
 'https://wallpaper.mob.org/image/fentezi-roboty-7002.html' ,
 'https://wallpaper.mob.org/image/chelovek-odinoko-odinochestvo-grust-art-150452.html' ,
 'https://wallpaper.mob.org/image/space-planeta-zemlya-kosmos-prostranstvo-142960.html' ,
 'https://wallpaper.mob.org/image/art-kosmicheskii_korabl-skali-landshaft-vnezemnoi-ptitsi-siyanie-avrora-tuman-155723.html',
 'https://wallpaper.mob.org/image/dark-luna-derevya-listya-vetki-noch-temnii-77455.html',
 'https://wallpaper.mob.org/image/dark-cherep-temnii-uzori-kosti-143967.html',
 'https://wallpaper.mob.org/image/nature-kamni-forma-bereg-more-voda-101134.html',
 'https://wallpaper.mob.org/image/dark-shakhmati-korol-figura-igra-doska-ten-temnii-85444.html',
 'https://wallpaper.mob.org/image/nature-polnolunie-ptitsi-pustinya-zvezdnoe_nebo-80403.html',
 'https://wallpaper.mob.org/image/astronavt-gigant-art-planeti-kosmos-108372.html',
 'https://wallpaper.mob.org/image/nature-derevo-poberezhe-more-gorizont-nebo-64935.html',
 'https://wallpaper.mob.org/image/nature-gora-ozero-ptitsa-nebo-gorizont-106821.html',
 'https://wallpaper.mob.org/image/zmeya-zelenii-reptiliya-cheshuya-3d-58344.html',
 'https://wallpaper.mob.org/image/animals-meduza-shchupaltsa-krasnii-pod_vodoi-134658.html',
 'https://wallpaper.mob.org/image/nature-monstera-liana-listya-kapli-rastenie-124323.html',
 'https://wallpaper.mob.org/image/space-tumannost-galaktika-meteori-kosmos-dvizhenie-svechenie-127653.html',
 'https://wallpaper.mob.org/image/abstract-rozovii-yarkii-liniya-svetlii-77426.html',
 'https://wallpaper.mob.org/image/artfoto-lvy-zhivotnye-15676.html',
 'https://wallpaper.mob.org/image/abstract-kraska-razvodi-zhidkost-sinii-abstraktsiya-124463.html',
 'https://wallpaper.mob.org/image/abstract-bliki-boke-raduga-raznotsvetnii-svetyashchiisya-temnii-154220.html',
 'https://wallpaper.mob.org/image/space-mars-planeta-korichnevii-poverkhnost-kosmos-79214.html',
 'https://wallpaper.mob.org/image/black-molniya-svechenie-chernii-87308.html',
 'https://wallpaper.mob.org/image/other-khrustalnii_shar-shar-sfera-otrazhenie-gorod-83104.html',
 'https://wallpaper.mob.org/image/animals-lisa-sneg-bezhat-zima-71212.html',
 'https://wallpaper.mob.org/image/city-eifeleva_bashnya-parizh-nochnoi_gorod-ogni_goroda-frantsiya-129995.html',
 'https://wallpaper.mob.org/image/city-eifeleva_bashnya-parizh-nochnoi_gorod-ogni_goroda-frantsiya-129995.html',
 'https://wallpaper.mob.org/image/food-morozhenoe-desert-pechene-zefir-stakan-100906.html',
 'https://wallpaper.mob.org/image/animals-tukan-ptitsa-ekzoticheskii-vetka-klyuv-okras-54414.html',
 'https://wallpaper.mob.org/image/abstract-linii-polosi-art-poverkhnost-83338.html',
 'https://wallpaper.mob.org/image/3d-sfera-molekuli-galaktika-86854.html',
 'https://wallpaper.mob.org/image/city-sidneiskii_opernii_teatr-nochnoi_gorod-gavan-most-sidnei-avstraliya-138973.html',
 'https://wallpaper.mob.org/image/devushki-kino-lyudi-skarlet_johansson_scarlett_johansson-47075.html',
 'https://wallpaper.mob.org/image/abstract-fraktal-uzor-simmetriya-svechenie-abstraktsiya-117642.html',
 'https://wallpaper.mob.org/image/black-molniya-svechenie-chernii-87308.html',
 'https://wallpaper.mob.org/image/nature-ptitsa-polet-solntse-bliki-oblaka-svoboda-visota-109285.html',
 'https://wallpaper.mob.org/image/mayaki-more-pejzazh-priroda-42551.html',
 'https://wallpaper.mob.org/image/space-galaktika-tumannost-zvezdi-kosmos-astronomiya-73963.html',
 'https://wallpaper.mob.org/image/fon-puzyri-20766.html',
 'https://wallpaper.mob.org/image/flowers-tsveti-podsolnukhi-derevyannii-tekstura-107348.html',
 'https://wallpaper.mob.org/image/movie-minions-bob_minions-kevin_minions-minions_movie-stuart_minions-687765.html',
 'https://wallpaper.mob.org/image/abstract-blue-cgi-1077544.html',
 'https://wallpaper.mob.org/image/abstract-illyuziya-psikhodelika-raznotsvetnii-art-62750.html',
 'https://wallpaper.mob.org/image/flowers-lotos-kuvshinka-voda-138169.html',
 'https://wallpaper.mob.org/image/art-leonardo_da_vinchi-mona_liza-liza_del_dzhokondo-portret-maslo-risovanie-135114.html',
 'https://wallpaper.mob.org/image/vector-sinii-belii-smail-risunok-58394.html',
 'https://wallpaper.mob.org/image/anime-one_piece-brook_one_piece-donquixote_doflamingo-edward_newgate-eustass_kid-franky_one_piece-kuzan_one_piece-marco_one_piece-monkey_d_luffy-nami_one_piece-nico_robin-portgas_d_ace-roronoa_zoro-sanji_one_piece-shanks_one_piece-silvers_rayleigh-smoker_one_piece-tony_tony_chopper-trafalgar_law-usopp_one_piece-359340.html',
 'https://wallpaper.mob.org/image/other-vozdushnie_shari-aerostati-polet-nebo-raznotsvetnii-143277.html',
 'https://wallpaper.mob.org/image/abstract-iskri-raznotsvetnii-feierverk-blesk-siyanie-149719.html',
 'https://wallpaper.mob.org/image/anime-babochki-smert-10850.html',
 'https://wallpaper.mob.org/image/3d-shariki-tsveta-poloski-56480.html',
 'https://wallpaper.mob.org/image/abstract-kraska-razvodi-fluid_art-abstraktsiya-zhidkost-blestki-85337.html',
 'https://wallpaper.mob.org/image/textures-graffiti-stena-kraska-tsveti-risunok-67394.html',
 'https://wallpaper.mob.org/image/celebrity-elon_musk-877040.html',
 'https://wallpaper.mob.org/image/art-olen-noch-luna-svechenie-bliki-71756.html',
 'https://wallpaper.mob.org/image/food-apelsin-led-myata-tsitrus-koltsa-tayushchii-51865.html',
 'https://wallpaper.mob.org/image/nature-poezd-zheleznaya_doroga-les-ozero-puteshestvie-87015.html',
 'https://wallpaper.mob.org/image/domik-art-tsveti-dvor-skazochnii-65383.html',
 'https://wallpaper.mob.org/image/abstract-poverkhnost-figuri-svetlii-155588.html',
 'https://wallpaper.mob.org/image/other-igralnie_kosti-kubiki-puziri-vsplesk-voda-79009.html',
 'https://wallpaper.mob.org/image/tigr-art-fantasticheskii-griva-svechenie-135178.html',
 'https://wallpaper.mob.org/image/nature-vinsent_van_gog-pshenichnoe_pole_s_kiparisami-pshenichnie_polya-maslo-kholst-86638.html',
 'https://wallpaper.mob.org/image/city-eifeleva_bashnya-parizh-frantsiya-dostoprimechatelnost-152302.html',
 'https://wallpaper.mob.org/image/flowers-maki-tsveti-rastenie-123224.html',
 'https://wallpaper.mob.org/image/animals-bengalskii_tigr-tigr-bolshaya_koshka-khishchnik-62495.html',
 'https://wallpaper.mob.org/image/animals-medved-sneg-progulka-zver-123920.html',
 'https://wallpaper.mob.org/image/macro-shar-steklo-otrazhenie-more-zakat-bereg-133498.html',
 'https://wallpaper.mob.org/image/textures-tekstura-relef-geometricheskii-obemnii-zelenii-104649.html',
 'https://wallpaper.mob.org/image/city-sidneiskii_opernii_teatr-nochnoi_gorod-gavan-most-sidnei-avstraliya-138973.html',
 'https://wallpaper.mob.org/image/asy-fon-zodiak-20146.html',
 'https://wallpaper.mob.org/image/nature-derevo-park-gorod-tsveti-157685.html',
 'https://wallpaper.mob.org/image/movie-the_batman-batman-dc_comics-512406.html',
 'https://wallpaper.mob.org/image/nature-fonar-most-sumerki-vecher-vid-117494.html',
 'https://wallpaper.mob.org/image/korabli-more-noch-pejzazh-transport-27131.html',
 'https://wallpaper.mob.org/image/animals-leopard-khishchnik-bolshaya_koshka-morda-148634.html',
 'https://wallpaper.mob.org/image/animals-kotenok-ten-vzglyad-temnii_fon-150911.html',
 'https://wallpaper.mob.org/image/flowers-maki-tsveti-krasnii-rastenie-tsvetenie-151564.html',
 'https://wallpaper.mob.org/image/other-voda-pod_vodoi-glubina-sinii-109463.html',
 'https://wallpaper.mob.org/image/astronavt-kosmos-art-planeta-risunok-chb-65686.html',
 'https://wallpaper.mob.org/image/space-planeta-zemlya-kosmos-prostranstvo-142960.html',
 'https://wallpaper.mob.org/image/abstract-linii-tochki-blesk-spletnie-147056.html',
 'https://wallpaper.mob.org/image/textures-poverkhnost-serii-temnii-svetlii-ten-156458.html',
 'https://wallpaper.mob.org/image/pejzazh-reka-vodopady-35461.html',
 'https://wallpaper.mob.org/image/nature-les-tropinka-derevya-razmitost-illyuziya-63118.html',
 'https://wallpaper.mob.org/image/nature-osen-tropinka-listva-les-derevya-osennie_kraski-69819.html',
 'https://wallpaper.mob.org/image/other-smail-smailik-shar-myach-zheltii-156862.html',
 'https://wallpaper.mob.org/image/abstract-polosi-abstraktsiya-krasnii-sinii-142864.html',
 'https://wallpaper.mob.org/image/macro-listya-poverkhnost-zelenii-zhilki-rastenie-makro-105571.html',
 'https://wallpaper.mob.org/image/fentezi-kino-zvezdnye_vojny_star_wars-19385.html',
 'https://wallpaper.mob.org/image/lyubov-klaviatura-serdtse-bukvi-151229.html',
 'https://wallpaper.mob.org/image/les-volshebstvo-babochki-fentezi-art-67940.html',
 'https://wallpaper.mob.org/image/pejzazh-priroda-tigry-zhivotnye-48663.html',
 'https://wallpaper.mob.org/image/flowers-tyulpani-tsveti-buket-krasnie-nebo-vesna-113781.html',
 'https://wallpaper.mob.org/image/aktery-kino-lyudi-muzhchiny-o_vse_tyazhkie_breaking_bad-17089.html',
 'https://wallpaper.mob.org/image/words-nadpis-motivatsiya-schaste-znaechenie-79657.html',
 'https://wallpaper.mob.org/image/anime-my_hero_academia-green_eyes-green_hair-izuku_midoriya-smile-410806.html',
 'https://wallpaper.mob.org/image/city-zdanie-gorod-doroga-naberezhnaya-sidnei-avstraliya-105771.html',
 'https://wallpaper.mob.org/image/anime-solo_leveling-sung_jin_woo-966673.html',
 'https://wallpaper.mob.org/image/animals-filin-ptitsa-korichnevii-dikaya_priroda-51989.html',
 'https://wallpaper.mob.org/image/artistic-pixel_art-8_bit-astronaut-fire-spacesuit-760055.html',
 'https://wallpaper.mob.org/image/cvety-fon-rasteniya-9927.html',
 'https://wallpaper.mob.org/image/nature-poberezhe-skali-vid_sverkhu-more-voda-91747.html',
 'https://wallpaper.mob.org/image/nature-okean-volna-lento-nebo-solnechnii-94999.html',
 'https://wallpaper.mob.org/image/nature-les-derevya-solnechnii_svet-peizazh-utro-54252.html',
 'https://wallpaper.mob.org/image/gora-vershina-derevya-oblako-priroda-149674.html',
 'https://wallpaper.mob.org/image/flowers-lotos-tsvetok-tsvetenie-vodoem-153656.html',
 'https://wallpaper.mob.org/image/demon-kapyushon-plashch-skelet-romb-art-82553.html',
 'https://wallpaper.mob.org/image/art-drakony-fon-12428.html',
 'https://wallpaper.mob.org/image/nature-derevya-les-dzhungli-mokh-kamni-zelenii-vetvi-korni-72014.html',
 'https://wallpaper.mob.org/image/words-misli-slova-motivatsiya-fraza-tsitata-tekst-56930.html',
 'https://wallpaper.mob.org/image/man_made-eiffel_tower-paris-1482143.html',
 'https://wallpaper.mob.org/image/video_game-genshin_impact-mona_genshin_impact-starry_sky-1008694.html',
 'https://wallpaper.mob.org/image/other-kot-kapyushon-geterokhromiya-temnii-sereznii-91740.html',
 'https://wallpaper.mob.org/image/dark-silueti-luna-noch-vershina-zvezdnoe_nebo-polnolunie-110914.html',
 'https://wallpaper.mob.org/image/vector-budda-buddizm-meditatsiya-garmoniya-siluet-92173.html',
 'https://wallpaper.mob.org/image/animals-popugai-ptitsa-vetki-listya-derevo-53143.html',
 'https://wallpaper.mob.org/image/abstract-kraska-razvodi-zhidkost-sinii-abstraktsiya-124463.html',
 'https://wallpaper.mob.org/image/nature-severnoe_siyanie-avrora-gora-sneg-led-norvegiya-138753.html',
 'https://wallpaper.mob.org/image/flowers-mak-tsvetok-trava-tsvetenie-makro-131030.html',
 'https://wallpaper.mob.org/image/animals-slon-les-dikaya_priroda-temnii-70547.html',
 'https://wallpaper.mob.org/image/other-chasi-vintazh-vremya-tsifri-82826.html',
 'https://wallpaper.mob.org/image/kapli-rasteniya-5231.html',
 'https://wallpaper.mob.org/image/other-samolyot-polyot-nebo-krilya-99264.html',
 'https://wallpaper.mob.org/image/ryby-zhivotnye-37669.html',
 'https://wallpaper.mob.org/image/chelovek-odinoko-odinochestvo-grust-art-150452.html',
 'https://wallpaper.mob.org/image/nature-doroga-tuman-derevya-chb-154694.html',
 'https://wallpaper.mob.org/image/nature-domik-zima-sneg-vecher-derevya-67118.html',
 'https://wallpaper.mob.org/image/animals-lev-khishchnik-bolshaya_koshka-kliki-vzglyad-78611.html',
 'https://wallpaper.mob.org/image/hi-tech-fotoapparat-obektiv-listya-72190.html',
 'https://wallpaper.mob.org/image/video_game-valorant-jett_valorant-983064.html',
 'https://wallpaper.mob.org/image/anime-naruto-gaara_naruto-green_eyes-tattoo-1523294.html',
 'https://wallpaper.mob.org/image/nature-ptitsi-silueti-voskhod-more-68746.html',
 'https://wallpaper.mob.org/image/macro-puzir-raznotsvetnii-krasochnii-poverkhnost-makro-pyatna-temnii_fon-83786.html',
 'https://wallpaper.mob.org/image/oleni-noch-art-zvezdnoe_nebo-meteorit-129616.html',
 'https://wallpaper.mob.org/image/aktery-halk_hulk-kino-muzhchiny-18554.html',
 'https://wallpaper.mob.org/image/flowers-roza-tsvetok-ogon-plamya-goret-155114.html',
 'https://wallpaper.mob.org/image/elovek-pauk_spider_man-kino-4137.html',
 'https://wallpaper.mob.org/image/flowers-roza-mokrii-lepestki-tsvetok-kapli-poverkhnost-151745.html',
 'https://wallpaper.mob.org/image/nature-yel-les-derevya-zvezdnoe_nebo-zvezdi-118488.html',
 'https://wallpaper.mob.org/image/animals-indiiskii_popugai-popugai-ptitsi-perya-yarkii-129029.html',
 'https://wallpaper.mob.org/image/words-nadpis-yumor-prikol-vozrazhenie-kasanie-glaza-152942.html',
 'https://wallpaper.mob.org/image/abstract-abstraktsiya-gradient-razmitost-tsvet-132253.html',
 'https://wallpaper.mob.org/image/anime-demon_slayer_kimetsu_no_yaiba-blonde-katana-kimetsu_no_yaiba-weapon-zenitsu_agatsuma-939692.html',
 'https://wallpaper.mob.org/image/words-restart-slovo-strelki-108175.html',
 'https://wallpaper.mob.org/image/babochka-knigi-art-bliki-magiya-112294.html',
 'https://wallpaper.mob.org/image/animals-tigr-vzglyad-khishchnik-trava-bolshaya_koshka-68616.html',
 'https://wallpaper.mob.org/image/holidays-paskha-prazdnik-yaitsa-krashennie-yarkie-gora-krasochnie-korzinka-104290.html',
 'https://wallpaper.mob.org/image/space-chernaya_dira-zatmenie-zvezdi-singulyarnost-planeta-prostranstvo-100835.html',
 'https://wallpaper.mob.org/image/abstract-fraktal-uzor-simmetriya-svechenie-abstraktsiya-117642.html',
 'https://wallpaper.mob.org/image/city-pagoda-arkhitektura-solnechnii_svet-yaponiya-115588.html',
 'https://wallpaper.mob.org/image/food-apelsin-led-myata-tsitrus-koltsa-tayushchii-51865.html',
 'https://wallpaper.mob.org/image/abstract-voda-brizgi-volna-linii-fon-sploshnoi-125436.html',
 'https://wallpaper.mob.org/image/pavliny-pticy-risunki-zhivotnye-9411.html',
 'https://wallpaper.mob.org/image/drakon-zmei-chelovek-fantastika-art-59777.html',
 'https://wallpaper.mob.org/image/betmen_batman-kino-risunki-21101.html',
 'https://wallpaper.mob.org/image/artistic-3d_art-3d-black-cube-dark-red-187556.html',
 'https://wallpaper.mob.org/image/other-vozdushnii_shar-shari-raznotsvetnii-skali-68533.html',
 'https://wallpaper.mob.org/image/sobaki-zhivotnye-33965.html',
 'https://wallpaper.mob.org/image/other-pesochnie_chasi-kamni-razmitost-131690.html',
 'https://wallpaper.mob.org/image/vector-kot-siluet-chernii-zheltii-minimalizm-52299.html',
 'https://wallpaper.mob.org/image/other-kofe-chashka-kniga-naushniki-tekst-71004.html',
 'https://wallpaper.mob.org/image/macro-vetka-dozhd-makro-listya-kapli-68749.html',
 'https://wallpaper.mob.org/image/space-planeta-zemlya-kosmos-prostranstvo-142960.html',
 'https://wallpaper.mob.org/image/nature-novaya_zelandiya-ostrov-ozero-uanaka-50812.html',
 'https://wallpaper.mob.org/image/movie-forbidden_planet-planet-robby_the_robot-612217.html',
 'https://wallpaper.mob.org/image/movie-forbidden_planet-planet-robby_the_robot-612217.html',
 'https://wallpaper.mob.org/image/city-arkhitektura-luzha-otrazhenie-gorod-praga-chekhiya-112045.html',
 'https://wallpaper.mob.org/image/animals-belogolovii_orel-orel-ptitsa-khishchnik-derevo-107914.html',
 'https://wallpaper.mob.org/image/abstract-kist-forma-svet-tsvet-dim-131974.html',
 'https://wallpaper.mob.org/image/love-serdechki-zamok-vorota-temnii-111198.html',
 'https://wallpaper.mob.org/image/dark-ruka-vetka-solntse-zakat-temnii-156378.html',
 'https://wallpaper.mob.org/image/fantasy-gorod-futurizm-sci_fi-budushchee-fantastika-157242.html',
 'https://wallpaper.mob.org/image/popugai-ptitsi-romantika-milii-art-51875.html',
 'https://wallpaper.mob.org/image/frukty-klubnika-rasteniya-smorodina-zhevika-16742.html',
 'https://wallpaper.mob.org/image/nature-listya-zhilki-kusti-vetki-98637.html',
 'https://wallpaper.mob.org/image/flowers-rozi-kolonna-dekorirovanie-sad-oformlenie-103658.html',
 'https://wallpaper.mob.org/image/art-derevo-pole-vozdushnie_shariki-leto-rebenok-55999.html',
 'https://wallpaper.mob.org/image/anime-one_piece-portgas_d_ace-tattoo-160405.html',
 'https://wallpaper.mob.org/image/silueti-para-lyubov-romantika-obyatiya-palmi-temnii-80778.html',
 'https://wallpaper.mob.org/image/macro-kapli-zhidkost-makro-goluboi-serii-54783.html',
 'https://wallpaper.mob.org/image/other-knigi-ochki-vaza-okno-podokonnik-tsveti-124430.html',
 'https://wallpaper.mob.org/image/city-doroga-dvizhenie-neboskrebi-mankhetten-nyu_iork-91898.html',
 'https://wallpaper.mob.org/image/other-karandashi-raznotsvetnii-tsveta-risovanie-131398.html',
 'https://wallpaper.mob.org/image/ozero-derevya-kamni-tuman-art-86374.html',
 'https://wallpaper.mob.org/image/nature-doroga-asfalt-povorot-les-derevya-58836.html',
 'https://wallpaper.mob.org/image/abstract-fraktal-zhidkost-volnistii-fioletovii-abstraktsiya-136144.html',
 'https://wallpaper.mob.org/image/nature-zakat-more-bliki-skali-nebo-118610.html',
 'https://wallpaper.mob.org/image/flowers-roza-tsvetok-ogon-plamya-goret-155114.html',
 'https://wallpaper.mob.org/image/vector-lodka-gori-zvezdopad-art-57874.html',
 'https://wallpaper.mob.org/image/volk-art-noch-temnii-111070.html',
 'https://wallpaper.mob.org/image/muzyka-naushniki-obekty-11171.html',
 'https://wallpaper.mob.org/image/flowers-sakura-tsveti-tsvetenie-vesna-rozovii-138012.html',
 'https://wallpaper.mob.org/image/other-babochki-risunok-polet-raznotsvetnie-fon-rozovii-130013.html',
 'https://wallpaper.mob.org/image/space-kosmos-planeta-oskolki-zvezdi-vselennaya-galaktika-58682.html',
 'https://wallpaper.mob.org/image/textures-risunok-formi-grafika-87884.html',
 'https://wallpaper.mob.org/image/nature-doroga-razmetka-derevya-les-nebo-62250.html',
 'https://wallpaper.mob.org/image/cars-porsche_carrera_gt-porsche_carrera-porsche-sportkar-superkar-gonka-svet-77489.html',
 'https://wallpaper.mob.org/image/abstract-linii-shtrikhi-sinii-fon-152608.html',
 'https://wallpaper.mob.org/image/nature-tsvetok-solntse-zakat-sumerki-temnii-72352.html',
 'https://wallpaper.mob.org/image/city-nochnoi_gorod-ulitsa-neon-ogni-doroga-zdaniya-105003.html',
 'https://wallpaper.mob.org/image/words-ulibka-slovo-dekor-ukrashenie-153409.html',
 'https://wallpaper.mob.org/image/nature-plyazh-palmi-pesok-voda-131074.html',
 'https://wallpaper.mob.org/image/flowers-tyulpan-trava-tsvetok-flora-tsvetenie-117612.html',
 'https://wallpaper.mob.org/image/other-poezd-gori-most-derevya-priroda-152465.html',
 'https://wallpaper.mob.org/image/nature-zakat-more-volni-bereg-sumerki-103630.html',
 'https://wallpaper.mob.org/image/gory-kamni-nebo-pejzazh-plyazh-3675.html',
 'https://wallpaper.mob.org/image/chelovek-odinoko-odinochestvo-grust-art-150452.html',
 'https://wallpaper.mob.org/image/macro-kapli-voda-makro-poverkhnost-temnii-147878.html',
 'https://wallpaper.mob.org/image/motorcycles-mototsikl-baik-vid_speredi-fara-zakat-100776.html',
 'https://wallpaper.mob.org/image/noch-fonari-ogni-art-temnii-128827.html',
 'https://wallpaper.mob.org/image/space-planeta-asteroidi-kosmos-gravitatsiya-110595.html',
 'https://wallpaper.mob.org/image/nature-vetki-nebo-minimalizm-94004.html',
 'https://wallpaper.mob.org/image/pejzazh-priroda-49488.html',
 'https://wallpaper.mob.org/image/medvedi-multfilmy-panda_kung-fu-13595.html',
 'https://wallpaper.mob.org/image/abstract-fraktal-tsvetok-bliki-blesk-abstraktsiya-79756.html',
 'https://wallpaper.mob.org/image/flowers-rozi-sad-kust-derevo-razmitost-97093.html',
 'https://wallpaper.mob.org/image/cvety-fon-rasteniya-9927.html',
 'https://wallpaper.mob.org/image/anime-muzhchiny-16994.html',
 'https://wallpaper.mob.org/image/domik-vecher-velosiped-art-reka-oblaka-75512.html',
 'https://wallpaper.mob.org/image/other-karti-kombinatsiya-chernii-154808.html',
 'https://wallpaper.mob.org/image/nature-lodka-gori-ozero-voda-gorizont-136417.html',
 'https://wallpaper.mob.org/image/movie-star_wars_episode_iv_a_new_hope-darth_vader-death_star-luke_skywalker-princess_leia-360881.html',
 'https://wallpaper.mob.org/image/tv_show-doctor_who-angel-weeping_angel_doctor_who-665501.html',
 'https://wallpaper.mob.org/image/tv_show-dalek-doctor_who-1520693.html',
 'https://wallpaper.mob.org/image/video_game-lego_star_wars_the_skywalker_saga-bb_8-chewbacca-c_3po-darth_vader-han_solo-kylo_ren-lightsaber-luke_skywalker-obi_wan_kenobi-princess_leia-rey_star_wars-yoda-491423.html',
 'https://wallpaper.mob.org/image/movie-star_wars-carrie_fisher-princess_leia-1516822.html',
 'https://wallpaper.mob.org/image/movie-star_wars_episode_vii_the_force_awakens-bb_8-star_wars-374315.html',
 'https://wallpaper.mob.org/image/movie-star_wars-anakin_skywalker-blue_lightsaber-jedi-lightsaber-obi_wan_kenobi-521304.html',
 'https://wallpaper.mob.org/image/sci_fi-star_wars-at_te-droid_gunship-kashyyyk_star_wars-star_wars_the_clone_wars-522876.html',
 'https://wallpaper.mob.org/image/movie-star_wars-cape-darth_vader-helmet-lightsaber-planet-red_lightsaber-sith_star_wars-521036.html',
 'https://wallpaper.mob.org/image/fentezi-kino-zvezdnye_vojny_star_wars-19385.html',
 'https://wallpaper.mob.org/image/tv_show-star_trek_the_original_series-354745.html',
 'https://wallpaper.mob.org/image/tv_show-star_trek_the_next_generation-dark-enterprise_star_trek-movie-planet-sci_fi-ship-space-star_trek-stars-521837.html',
 'https://wallpaper.mob.org/image/fon-kino-logotipy-star_trek_zvezdnyj_put-20228.html',
 'https://wallpaper.mob.org/image/animals-morskaya_cherepakha-cherepakha-podvodnii_mir-plavanie-57357.html',
 'https://wallpaper.mob.org/image/nature-tsvetok-solntse-zakat-sumerki-temnii-72352.html',
 'https://wallpaper.mob.org/image/tv_show-spaceship-babylon_5-1434143.html',
 'https://wallpaper.mob.org/image/abstract-detskie-solntse-babochki-tsveti-ulibki-zavitok-116061.html',
 'https://wallpaper.mob.org/image/animal-tawny_frogmouth-bird-300765.html',
 'https://wallpaper.mob.org/image/movie-the_princess_and_the_frog-tiana_the_princess_and_the_frog-176018.html',
 'https://wallpaper.mob.org/image/animal-tree_frog-339845.html',
 'https://wallpaper.mob.org/image/animal-poison_dart_frog-blue_poison_dart_frog-frog-310350.html',
 'https://wallpaper.mob.org/image/animal-red_eyed_tree_frog-frog-159043.html',
 'https://wallpaper.mob.org/image/animal-cat-stare-191307.html',
 'https://wallpaper.mob.org/image/grib-chastitsi-trava-art-146642.html',
 'https://wallpaper.mob.org/image/humor-funny-1080982.html',
 'https://wallpaper.mob.org/image/animal-poison_dart_frog-388047.html',
 'https://wallpaper.mob.org/image/animals-lyagushka-krasnie_glaza-stebel-zelyonii_fon-149929.html',
 'https://wallpaper.mob.org/image/lyagushki-zhivotnye-35387.html',
 'https://wallpaper.mob.org/image/movie-crossover-fujimoto_ponyo-howl_s_moving_castle-kiki_s_delivery_service-kiki_kiki_s_delivery_service-laputa_castle_in_the_sky-my_neighbor_totoro-nausica%C3%A4-ponyo_on_the_cliff_by_the_sea-ponyo-porco_rosso-princess_mononoke-spirited_away-studio_ghibli-tales_from_earthsea-the_wind_rises-totoro_my_neighbor_totoro-930506.html',
 'https://wallpaper.mob.org/image/anime-howl_s_moving_castle-howl_jenkins_pendragon-sophie_hatter-916522.html',
 'https://wallpaper.mob.org/image/anime-howl_s_moving_castle-black_hair-cloud-flower-long_hair-mountain-white_hair-966042.html',
 'https://wallpaper.mob.org/image/anime-spirited_away-chihiro_spirited_away-haku_spirited_away-studio_ghibli-780149.html',
 'https://wallpaper.mob.org/image/anime-spirited_away-chihiro_spirited_away-dragon-haku_spirited_away-159316.html',
 'https://wallpaper.mob.org/image/dark-city-ghost-172230.html'
 )


rip_url <- function(url){
  webpage  <- read_html(url)
  main_image    <- html_nodes(webpage,'#main-image') 
  image <- xml_attr(main_image[[1]],'data-url')

  next_xml <- xml_attrs(html_nodes(webpage,'.page-image__image-block-button-link'))
  next_url <- as.character(paste0('https:',next_xml[[1]][1]))
  
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

if (file.exists(paste0(PROJECT_DIR,"/mobile.RData"))){
  load(paste0(PROJECT_DIR,"/mobile.RData"))  # Load the data file if it exists
} else {
  mobile <- rip_url(url)  # Initialise with  first page
}

# Download images starting from each URL until they start to repeat
for (url in urls){
  print(paste("Starting ripping from url",url))
  url_set <- rip_url(url)
  continue <- TRUE
  i <-  1
  while (continue==TRUE){
    url <- tail(url_set$next_url,1)
    print(paste("Iteration",i,"Looking up page",url))
    new_url <- tryCatch({rip_url(url)},error=function(e){})
    new_url <- anti_join(new_url,url_set,by=join_by(url))
    if (nrow(new_url)==0) {
      continue <- FALSE
    } else {
        url_set <- rbind(url_set,new_url)
        }
    i <- i+1
  }
  mobile <- rbind(mobile,url_set)
  mobile <- unique(mobile)  # remove dupes
  save(mobile,file=paste0(PROJECT_DIR,"/mobile.RData"))
}

mobile <- unique(mobile)  # remove dupes
save(mobile,file=paste0(PROJECT_DIR,"/mobile.RData"))

# Download the Images
# Include image number at the start of name.

n <- nrow(mobile)
for (i in 1:nrow(mobile)){
  name <- mobile$image_name[i]
  if (file.exists(paste0(FILE_DIR,"/",name))){
    print(paste("File",paste0(FILE_DIR,"/",name),"Already Exists"))
  } else{
    print(paste("downloading file",i,"of",n,name))
    download.file(mobile$image[i],
                  paste0(FILE_DIR,"/",name),
                  quiet=TRUE, mode="wb")
  }
}

