server <- function(input, output, session) {
  # Loading Data ----
  data <- read.csv("../covid_06042020_choice_values.csv", header = T, stringsAsFactors = F)
  data <- data[3:nrow(data),]
  
  # Creating Variables ----
  
  #if(file.exists("../Unique_CountryName_full.csv"))
  #{
    Unique_CountryName_full <- read.csv("../Unique_CountryName_full.csv", header = T, stringsAsFactors = F)$x
  #}else{
  #  Unique_CountryName_full <- unique(toTitleCase(tolower(data$Country)))
  #  Unique_CountryName_full <- sort(Unique_CountryName_full[Unique_CountryName_full!=""])
  #  Unique_CountryName_full <- c(Unique_CountryName_full, "World")
    #execute the following line to speed up the process (not generate country names at every run)
    #write.csv(Unique_CountryName_full,"Unique_CountryName_full.csv", row.names = TRUE)
  #}
  
  updateSelectizeInput(session, 'CountryChoice', choices = Unique_CountryName_full, server = TRUE,
                       selected=c("France", "Italy"))
  
  #Beginning of the dynamic part
  observeEvent({
    input$CountryChoice
  },{
  
  country_list <- input$CountryChoice
  #country_list <- c("France", "Italy")
    
  #Generating Gender 100% barplot ----
  
  
    
  genders <- c("Female","Male","Other/would rather not say")
  
  processed_data = data %>%
    filter(Country%in%country_list,Dem_gender != "") %>%
    group_by(Country,Dem_gender) %>%
    summarise(nb_surveyed=n()) %>%
    ungroup() %>%
    group_by(Country) %>%
    mutate(perc_surveyed_by_country = (nb_surveyed / sum(nb_surveyed)) * 100) %>%
    ungroup() %>%
    mutate(country_gender_text = paste0(
      "Country: ", Country, "\n",
      "Gender: ", Dem_gender, "\n",
      "# of surveyed: ", nb_surveyed, "\n",
      "% of surveyed: ", round(perc_surveyed_by_country, 2), "\n"))
  processed_data$Country <- factor(processed_data$Country, levels = rev(country_list))
  processed_data$Dem_gender <- factor(processed_data$Dem_gender, levels = rev(genders))
  pGender100 <- ggplot(data = processed_data) +
    geom_bar(aes(x = Country, y = perc_surveyed_by_country, fill = Dem_gender, text = country_gender_text), stat="identity") +
    scale_fill_manual(name="Gender", values=c("Female" = "#00c7b8ff", "Male" = "#31233bff","Other/would rather not say" = "#fbedcdff")) +
    coord_flip() +
    labs(x = "Country", y = "% Gender") +
    theme_classic()
  
  
  output$PlotlyGender100<-renderPlotly({ ggplotly(pGender100, tooltip = "text") })
  output$PlotGender100<-renderPlot({pGender100})
  
  })
}