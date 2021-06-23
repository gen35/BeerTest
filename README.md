# BeerTest

Basic implementation for "Beer test" task.

## Usage

1. Build container (~500MB): 
```
docker build -t beertest:latest .
```
2. Run interactive shell:
```
docker run -it --rm beertest:latest
```
3. Run main() (first run will include compilation)
```julia
main(51., 10.) 
```

## Advanced usage

Use @time macro to get run time and memory allocations
```julia
@time main(50., 10.)
```

Save precomputed state to speed up main()
```julia
state = initialize();
@time main(50., 10.; state)
@time main(51., 10.; state)
```

Access Julia documentation directly from shell by typing '?' followed by desired function/operator/constant
```julia
help?> π
"π" can be typed by \pi<tab>

search: π

  π
  pi

  The constant pi.

  Examples
  ≡≡≡≡≡≡≡≡≡≡

  julia> pi
  π = 3.1415926535897...
```

## Example output

```julia
julia> @time state = initialize();
  0.098246 seconds (99.00 k allocations: 61.226 MiB, 11.28% gc time)

julia> @time main(51., 10.; state)
50km Martini-Brauerei +4
57km Htt-Brauerei Bettenhuser +1
136km Warsteiner Brauerei +4
157km Brauerei C. & A. Veltins GmbH & Co. +1
209km Dortmunder Actien Brauerei  DAB +4
239km Brauerei Schwelm +2
276km Gatz Brauhaus +3
276km Uerige Obergrige Hausbrauerei +3
276km Hausbrauerei Zum Schlssel +1
278km Brauhaus Johann Albrecht - Dsseldorf +2
282km Brauerei Schumacher +1
283km Privatbrauerei Frankenheim +1
304km Privatbrauerei Bolten +1
308km Hannen Brauerei +2
335km Bierbrouwerij St.Christoffel +2
364km Brouwerij Sint-Jozef +1
380km Brouwerij der Sint-Benedictusabdij de Achelse Kluis +5
387km Brouwerij De Achelse Kluis +3
424km Bierbrouwerij De Koningshoeven +16
442km de dochter van de korenaar +3
455km Brouwerij Sterkens +9
472km Brouwerij Abdij der Trappisten van Westmalle +2
493km Microbrouwerij Achilles +1
513km Brouwerij Het Anker +5
523km Brouwerij Duvel Moortgat +2
532km Brouwerij Bosteels +3
536km Brouwerij De Landtsheer +5
562km De Proef Brouwerij +17
570km Brouwerij Van Steenberge +12
579km ICOBES b.v.b.a. +1
595km Brouwerij The Musketiers +1
604km De Leyerth Brouwerijen +6
621km De Halve Maan +4
622km Brouwerij de Gouden Boom +1
624km Brouwerij De Regenboog +1
644km Brouwerij Strubbe +1
655km Brouwerij De Dolle Brouwers +6
671km De Struise Brouwers +3
674km Brouwerij Abdij Saint Sixtus +3
683km Brouwerij St. Bernardus +9
685km Brouwerij Van Eecke +3
696km Brasserie De Saint Sylvestre +2
709km Brasserie Thiriez +1
761km Brasserie Bnifontaine +3
783km Brasserie Grain D'Orge +1
807km Brouwerij De Ranke +4
817km Brouwerij Bavik - De Brabandere +8
824km Brouwerij Van Honsebrouck +4
825km Van Honsebrouch +1
825km Alvinne Picobrouwerij +1
835km Brouwerij Rodenbach +3
856km Brouwerij Bockor +1
866km Brouwerij Verhaeghe +3
881km Liefmans Breweries +4
900km Brouwerij Liefmans +6
901km Brasserie Clarysse +1
906km Brouwerij Roman +1
915km Brasserie Ellezelloise +4
935km Brasserie Dupont +6
941km Brasserie Dubuisson +4
955km Brasserie de Brunehaut +9
966km Daas +2
1005km Brasserie La Choulette +3
1028km Brasserie Duyck +3
1038km Brasserie De L'Abbaye Des Rocs +10
1045km Brasserie de Blaugies +3
1073km Brasserie des Gants +2
1085km Brasserie de Silly +6
1101km Brasserie Lefebvre +3
1108km Brouwerij Boon +5
1113km Hanssens Artisanal +3
1117km Brouwerij Oud Beersel +1
1118km 3 Fonteinen Brouwerij Ambachtelijke Geuzestekerij +2
1123km Brasserie de la Senne +4
1127km Brouwerij Lindemans +5
1129km Timmermans +7
1135km Brewery De Troch +6
1145km Brouwerij Slaghmuylder +2
1155km Brouwerij Van Den Bossche +2
1164km Kleinbrouwerij de Glazen Toren +3
1181km Brouwerij De Smedt +3
1181km Affligem Brouwerij +1
1184km Brouwerij De Block +2
1188km Palm Breweries +1
1198km Brouwerij De Keersmaeker +1
1208km Brasserie-Brouwerij Cantillon +10
1209km Brewery Belle-Vue +1
1228km John Martin sa +1
1260km Brasserie d'Ecaussinnes +3
1267km Brouwerij St-Feuillien +2
1278km Brasserie La Binchoise +3
1296km Brouwerij Alken-Maes +1
1320km Brasserie De Silenrieux +2
1341km Chimay (Abbaye Notre Dame de Scourmont) +4
1349km Brasserie de l'Abbaye de Scourmont (Trappistes) +2
1397km Abbaye de Maredsous +3
1409km Abbaye de Leffe +2
1416km Brasserie La Caracole +4
1428km Brasserie du Bocq +3
1452km Abbaye Notre Dame du St Remy +3
1474km Brasserie Fantme +4
1497km Brasserie D'Achouffe +5
1547km Brasserie Artisanale de Rulles +2
1621km Bitburger Brauerei +1
1704km Brennerei-Distillerie Radermacher +2
Beer count: 362
  0.247736 seconds (48.41 k allocations: 2.807 MiB)
362
```
