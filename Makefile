governors.csv:
	curl -o governors.csv https://projects.fivethirtyeight.com/congress-model-2018/governor_state_forecast.csv

gov.html: gov.R governors.csv current-gov.csv fun.R write-Rmd.R
	Rscript write-Rmd.R
