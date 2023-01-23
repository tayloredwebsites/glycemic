UsingTheAPI.md

# Using the API

Food Data Central: https://fdc.nal.usda.gov/index.html

Food Search: https://fdc.nal.usda.gov/fdc-app.html

Rolled Oats SR Legacy Food: https://fdc.nal.usda.gov/fdc-app.html#/food-details/173904/nutrients
- Data Type:SR Legacy Food
- Category:Breakfast Cereals
- FDC ID: 173904
- NDB Number:8120
- Portion: 100g
- Protein 	13.2 	g
- Total lipid (fat) 	6.52 	g
- Carbohydrate, by difference 	67.7 	g
- Fiber, total dietary 	10.1 	g
- Sugars, total including NLEA 	0.99 	g
- Calcium, Ca 	52 	mg
- Magnesium, Mg 	138 	mg
- Phosphorus, P 	410 	mg
- Potassium, K 	362 	mg

API call:
https://api.nal.usda.gov/fdc/v1/foods/search?query=apple&pageSize=2&api_key=some_key_from_usda


## NOTES:

PRAL of a food =  
  0.49 x protein (gram)  
  \+  0.037 x phosphorus (mg) 
  \- 0.021 x potassium (mg) 
  \- 0.026 magnesium (mg) 
  \- 0.013 x calcium (mg) 

  [Markdown Syntax](https://www.markdownguide.org/basic-syntax)

[using latex - not working](https://stackoverflow.com/questions/65920958/vs-code-latex-syntax-in-markdown#69707379)
  \alpha
    \infty
    sqrt{\alpha^2}

[LaTeX in Webpage](https://stackoverflow.com/questions/116054/what-is-the-best-way-to-embed-latex-in-a-webpage#10871521)
