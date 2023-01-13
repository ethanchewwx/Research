import scrapy
import csv
import base64

FILEPATH = *file directory*
FILENAME = *scraped reviews file*

def get_urls_from_csv():
    """Reads the scraped company reviews dataset and returns a list of user url links"""
    with open(FILEPATH + FILENAME,
              encoding="utf8") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        # user_urls = list(set(['https://uk.trustpilot.com' + row[0] for row in csv_reader][1:]))
        user_urls = list(set(['https://uk.trustpilot.com' + row[6] for row in csv_reader][1:]))
        return user_urls


# spider to scrape reviews left by the users which left reviews on digital banks, posted on trustpilot
class UserSpiderXPath(scrapy.Spider):
    name = 'user_key'
    # start_urls = ['https://uk.trustpilot.com/users/60636a29bd9132001982c2fa']

    def start_requests(self):
        """Calls the get_urls_from_csv function to get a list of user urls"""
        return [scrapy.http.Request(url=start_url) for start_url in get_urls_from_csv()]

    def parse(self, response):
        """Scrapes the user's page and outputs various components of the user, stored in a list, including:
        the ratings and reviews they've left, the companies they've reviewed and the date of each review"""
        user_url = response.xpath('//div[@class="styles_consumerDetailsWrapper__p2wdr"]/a/@href').get()
        user_name = response.xpath('//div[@class="styles_consumerDetailsWrapper__p2wdr"]/a/div/text()').get()
        user_img = response.xpath('//div[@class="avatar_imageWrapper__8wdWb"]/span/img/@src').get()
        self.set_user_reviews_to_empty()  # reinitialise the lists
        review_num = 0
        for user_review in response.xpath('//div[@class="styles_reviewListItem__j2OA3"]'):
            review_num += 1
            review_date = user_review.xpath('.//div/article/section/div[@class="styles_reviewHeader__iU9Px"]/'
                                            'div[@class="typography_typography__QgicV typography_bodysmall__irytL '
                                            'typography_color-gray-6__TogX2 typography_weight-regular__TWEnf '
                                            'typography_fontstyle-normal__kHyN3 styles_datesWrapper__RCEKH"]/time/'
                                            '@datetime').get()
            if review_date is None:
                review_date = user_review.xpath('.//div/article/section/div[@class="styles_reviewHeader__iU9Px"]/'
                                                'div[@class="typography_typography__QgicV typography_bodysmall__irytL '
                                                'typography_color-gray-6__TogX2 typography_weight-regular__TWEnf '
                                                'typography_fontstyle-normal__kHyN3 styles_datesWrapper__RCEKH"]/'
                                                'span/time/@datetime').get()

            review_dict = {
                'company_reviewed': user_review.xpath('.//p/a/text()').extract(),
                'user_rating': user_review.xpath('.//div/article/section/div/div/img/@alt').extract()[0][6],
                'review_title': user_review.xpath('.//div/article/section/div[@class="styles_reviewContent__0Q2Tg"]/'
                                                  'h2/a/text()').extract(),
                'review_text': user_review.xpath('.//div/article/section/div[@class="styles_reviewContent__0Q2Tg"]/'
                                                 'p/text()').extract(),
                'review_date': review_date
            }

            review_details[str(review_num)] = review_dict

        # scrapes all available pages and stops when there are no further pages to scrape
        next_page_user_url = response.xpath('//div/nav/a[@name="pagination-button-next"]/@href').extract_first()
        if next_page_user_url is not None:
            yield scrapy.Request(response.urljoin(next_page_user_url))

        yield {
            'user_url': user_url,
            'user_name': user_name,
            'user_img': user_img,
            'review_details': review_details,
        }

    def set_user_reviews_to_empty(self):
        """A function to declare and reinitialise the lists"""
        global review_details
        review_details = {}


