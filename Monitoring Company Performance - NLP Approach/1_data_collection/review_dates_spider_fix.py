import scrapy
import csv
import base64

FILEPATH = 'C:/Users/Ethan Chew/Desktop/Work/Individual Project/Internship/webscraping/'
FILENAME = 'review_missing_dates_users_urls.csv'
bank_names = ['N26', 'Wise (formerly TransferWise)', 'Starling Bank', 'Monzo', 'Revolut', 'HSBC UK',
              'Lloyds Bank', 'NatWest', 'Barclays', 'Santander']

def get_urls_from_csv():
    """Reads the scraped company reviews dataset and returns a list of user url links"""
    with open(FILEPATH + FILENAME,
              encoding="utf8") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        user_urls = ['https://uk.trustpilot.com' + row[0] for row in csv_reader]
        return user_urls


# spider to scrape reviews left by the users which left reviews on digital banks, posted on trustpilot
class UserSpiderXPath(scrapy.Spider):
    name = 'user_fix'

    def start_requests(self):
        """Calls the get_urls_from_csv function to get a list of user urls"""
        return [scrapy.http.Request(url=start_url) for start_url in get_urls_from_csv()]

    def parse(self, response):
        """Scrapes the user's page to scrape the remaining reviews that were incorrectly informatted - here it scrapes
        for review dates which were not originally recorded due to users editing their reviews"""
        user_url = response.xpath('//div[@class="styles_consumerDetailsWrapper__p2wdr"]/a/@href').get()
        for user_review in response.xpath('//div[@class="styles_reviewListItem__j2OA3"]'):
            company = user_review.xpath('.//p/a/text()').extract()

            if company[0] in bank_names:
                review_date = user_review.xpath('.//div/article/section/div[@class="styles_reviewHeader__iU9Px"]/'
                                                'div[@class="typography_typography__QgicV typography_bodysmall__irytL '
                                                'typography_color-gray-6__TogX2 typography_weight-regular__TWEnf '
                                                'typography_fontstyle-normal__kHyN3 styles_datesWrapper__RCEKH"]/'
                                                'span/time/@datetime').get()

                if review_date is None:
                    review_date = user_review.xpath('.//div/article/section/div[@class="styles_reviewHeader__iU9Px"]/'
                                                    'div[@class="typography_typography__QgicV typography_bodysmall__irytL '
                                                    'typography_color-gray-6__TogX2 typography_weight-regular__TWEnf '
                                                    'typography_fontstyle-normal__kHyN3 styles_datesWrapper__RCEKH"]/time/'
                                                    '@datetime').get()
                yield {
                    'user_url': user_url,
                    'company': company,
                    'date': review_date
                }

        # scrapes all available pages and stops when there are no further pages to scrape
        next_page_user_url = response.xpath('//div/nav/a[@name="pagination-button-next"]/@href').extract_first()
        if next_page_user_url is not None:
            yield scrapy.Request(response.urljoin(next_page_user_url))