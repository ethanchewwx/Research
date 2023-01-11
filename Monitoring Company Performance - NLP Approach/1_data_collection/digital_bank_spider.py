import scrapy

# spider to scrape reviews of digital banks, posted on trustpilot
class DigitalBankSpiderXPath(scrapy.Spider):
    name = 'digital_bank'
    start_urls = ['https://uk.trustpilot.com/review/www.monzo.com',
                  'https://uk.trustpilot.com/review/starlingbank.com',
                  'https://uk.trustpilot.com/review/wise.com',
                  'https://uk.trustpilot.com/review/www.revolut.com']  # scraping reviews from various digital banks

    def parse(self, response):
        """Scrapes a webpage and outputs various components of a review, including the rating (stars), date of review,
        the review itself, geo-location, etc."""
        company_name = response.xpath('//div[@id="business-unit-title"]/h1/span/text()').extract()
        for review in response.xpath('//div[@class="paper_paper__1PY90 paper_square__lJX8a card_card__lQWDv '
                                     'card_noPadding__D8PcU styles_cardWrapper__LcCPA styles_show__HUXRb '
                                     'styles_reviewCard__9HxJJ"]/article'):
            user = review.xpath('./aside/div/a')
            rating_date = review.xpath('.//section[@class="styles_reviewContentwrapper__zH_9M"]/'
                                       'div[@class="styles_reviewHeader__iU9Px"]')
            title_text = review.xpath('.//section[@class="styles_reviewContentwrapper__zH_9M"]/'
                                      'div[@class="styles_reviewContent__0Q2Tg"]')

            yield {
                'company': company_name[0],
                'rating': rating_date.xpath('./div[@class="star-rating_starRating__4rrcf star-rating_medium__iN6Ty"]/'
                                            'img/@alt').extract(),
                'date': rating_date.xpath('.//div[@class="typography_typography__QgicV typography_bodysmall__irytL '
                                          'typography_color-gray-6__TogX2 typography_weight-regular__TWEnf '
                                          'typography_fontstyle-normal__kHyN3 styles_datesWrapper__RCEKH"]/time/'
                                          '@datetime').extract(),
                'title': title_text.xpath('./h2/a/text()').extract(),
                'text': title_text.xpath('.//p/text()').extract(),
                'company_reply': review.xpath('.//div[@class="styles_wrapper__ib2L5"]/'
                                              'div[@class="styles_content__Hl2Mi"]/p/text()').extract(),
                'user_url': user.xpath('./@href').extract(),
                'user_num_reviews': user.xpath('.//div[@class="styles_consumerExtraDetails__fxS4S"]/'
                                               '@data-consumer-reviews-count').extract(),
                'user_geo_location': user.xpath('.//div[@class="styles_consumerExtraDetails__fxS4S"]/'
                                                'div/span/text()').extract(),
            }

        # scrapes all available pages and stops when there are no further pages to scrape
        next_page_url = response.xpath('//div[@class="styles_pagination__6VmQv"]/nav/'
                                       'a[@name="pagination-button-next"]/@href').extract_first()
        if next_page_url is not None:
            yield scrapy.Request(response.urljoin(next_page_url))
