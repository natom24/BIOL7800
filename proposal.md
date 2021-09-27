---
title: "Modeling Trophic Cascades due to Toxic Algal Blooms"
author: "Nathaniel Haulk"
output: html_document
---


### Introduction:

Trophic cascades are a phenomenon where a change in the number of predators that lead to large shifts in prey populations. These changes in population are often caused by extreme environmental events leading to large die-offs or the removal of individuals (Daskalov 2002). Algal blooms, often caused by the addition of pollutants like nitrogen and phosphate, are a major cause of mortality in aquatic communities. these blooms decrease the amount of dissolved oxygen in a system and can lead to massive die off if water is made hypoxic. Some algae species can also release cyanotoxins into the environment that are poisonous to the organisms in the water (White et al, 2005). These large die-outs often disproportionately affect the predator populations and can actually lead to situations where prey populations benefit from these large die-off. However, little work has gone into understanding how different intensities of algal blooms affect predator-prey relationships. Few studies have also looked into how predator-prey systems with numerous species can be affected by trophic cascades. Using mathematical models, I hope to provide a better understanding of when trophic cascades will occur and how changes in intensity of algal blooms can affect the population sizes of both predators and prey.

### Data Collection:

The majority of the data here will be modeled using differential equations to graph changes in population size. Parameters used when calculating changes in populations will either be calculated by hand or pulled from other literature sources that have performed similar experiments. For example, the natural mortality of predator and prey species will be derived from literature on aquatic organisms (Kidd et al, 2007). Parameters such as mortality caused by algal blooms will be calculated using R depending on the strength of the bloom. 


### Questions to Answer:

1. How do algal blooms affect systems with one predator species and one prey species?   
2. How do these blooms affect systems with numerous predator species and numerous prey species?  
3. How does changing the intensity of algal blooms affect these organisms?  
4. In what situations do we see positive benefits to prey systems?  
5. Are there situations where we see positive benefit to predator systems?  
6. Does the species of algae matter in how organisms will react to the blooms? 


### Sources:

Daskalov, G. M. (2002). Overfishing drives a trophic cascade in the Black Sea. *Marine Ecology Progress Series*, 225, 53-63.
  
Kidd, K. A., Blanchfield, P. J., Mills, K. H., Palace, V. P., Evans, R. E., Lazorchak, J. M., & Flick, R. W. (2007). Collapse of a fish population after exposure to a synthetic estrogen. *Proceedings of the National Academy of Sciences*, 104(21), 8897-8901.
  
White, S. H., Duivenvoorden, L. J., & Fabbro, L. D. (2005). Impacts of a toxic Microcystis bloom on the macroinvertebrate fauna of Lake Elphinstone, Central Queensland, Australia. *Hydrobiologia*, 548(1), 117-126.



