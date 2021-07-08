install.packages(c('dplyr','httr','jsonlite','rjava','Rselenium','stringr'))
install.packages("RSelenium")
library(dplyr)
library(httr)
library(jsonlite)
library(rJava)
library(RSelenium)
library(stringr)
library(rvest)
remDr<-remoteDriver(remoteServerAddr="localhost", port=4444L, browserName="chrome")

remDr$open()

remDr$navigate('https://play.google.com/store/apps/details?id=com.kakaogames.odin&showAllReviews=true')

webElem <- remDr$findElement("css", "body") #css의 body를 element로 찾아 지정
webElem$sendKeysToElement(list(key = "end")) #해당 element(화면)의 끝(end)으로 이동

flag <- TRUE #while문 종료 플래그
endCnt <- 0 #시간 측정 변수

while (flag) {
  Sys.sleep(10) #10초 대기
  webElemButton <- remDr$findElements(using = 'css selector',value = '.ZFr60d.CeoRYc') #'더보기' 버튼 element 찾아 지정
  
  if(length(webElemButton)==1){ #버튼이 나타난 경우 진입
    endCnt <- 0 #시간 측정 초기화
    webElem$sendKeysToElement(list(key = "home")) #화면의 처음(home)으로 이동
    webElemButton <- remDr$findElements(using = 'css selector',value = '.ZFr60d.CeoRYc')
    remDr$mouseMoveToLocation(webElement = webElemButton[[1]]) #해당 버튼으로 포인터 이동
    remDr$click() #마우스 클릭 액션
    webElem$sendKeysToElement(list(key = "end")) #해당 화면의 끝(end)으로 이동
  }else{
    if(endCnt>3){ #30초 이상 대기한 경우 진입
      flag <- FALSE #while문 종료
    }else{
      endCnt <- endCnt + 1 #대기 시간 증가
    }
  }
}
frontPage <- remDr$getPageSource()
library(httr)
reviewComments <- read_html(frontPage[[1]]) %>% html_nodes('.UD7Dzf') %>%  html_text()
reviewStars <- read_html(frontPage[[1]]) %>% html_nodes('.nt2C1d')
reviewStars  
reviewStars <- substr(reviewStars,68,69)
reviewData <- data.frame(comment=reviewComments,star=reviewStars)
write.csv(reviewData, paste0("stepsAppReview(",nrow(reviewData),").csv"))
reviewData$star <- as.numeric(reviewData$star)
mean(reviewData$star)
str(reviewData)

positive.review <- subset(reviewData,star > mean(star))
negative.review <- subset(reviewData,star < mean(star))
library(RColorBrewer)
library(wordcloud)
library(KoNLP)
useSejongDic()
negative.review$comment <- as.character(negative.review$comment)
negative.data <- sapply(negative.review$comment, extractNoun, USE.NAMES =F)
unlist.data <- unlist(negative.data)
wordcount <- table(unlist.data)
wordcount
top.wordcount <- head(sort(wordcount,decreasing = T),100)
wordcloud(names(top.wordcount),top.wordcount)
