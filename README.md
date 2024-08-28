# crayfish_density

 **Gebruik**
 
 Deze repository bevat de scripts en data voor de berekeningswijze van de populatiegrootte voor invasieve rivierkreeften zoals beschreven in het rapport Steen et al (2024).
 De folder src omvat 3 scripts:
  1. construct_inpfile: deze code zet de data ingevoerd in het veldformulier om in de inp-file die dient als input voor de berekeningen
  2. estim_dens_report: deze code voert de berekeningswijze uit zoals uitgevoerd in het rapport en omvat 3 modellen (m0, mt & mb)
  3. estim_dens: deze code voert de bewerking uit als voorgesteld in het rapport en omvat 2 modellen (m0 & mt)

**Structuur**

Deze repo omvat de volgende folders:
	1. src: bevat alle scripts
 	2. localities: folder met data en bewerkingen
		Voor elk van de metingen beschreven in het rapport werd een folder opgemaakt genaamd YYYY_MM_'localiteit'. Voor het uitvoeren van berekeningen voor nieuwe localiteiten, dient er een nieuwe folder gemaakte te worden met dezelfde naam. Elke folder bevat 2 subdirectories: 
				1. input: ingevulde veldformulier (Veldformulier_LOCALITY_MM_YYYY) & inpfiles
				2. output: de genereerde output van de berekeningen in een tekstfile
