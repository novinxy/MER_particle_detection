# This project is used for grain detection from MI pictures from MER mission

Project was written in Matlab language, and it contains several files:

- Binarization.m - contains particle detection function using image binarization as segmentation step
- Canny.m - contains particle detection function using Canny edge detection as segmentation step
- Watershed.m - contains particle detection function using watershed as segmentation step

Each of those function can be used indepently from Matlab command window, or in another script.

Signature of those function looks like:

- function Binarization(file_name, log, radius, thresh_level),

    where:
    - file_name - path to image
    - radius - radius for kernel(in shape of disk) used for morphological opening
    - log - flag indicating that pitures from each step should be saved
    - thresh_level - thresh level used in binarization step, can be omitted, in such situation, algorithm will use Otsu threshold

- function Canny(file_name, log, radius, thresh, sigma)

    where:
    - file_name - path to image
    - radius - radius for kernel(in shape of disk) used for morphological opening
    - log - flag indicating that pitures from each step should be saved
    - thresh - threshold for Canny detection, it should be vector2d [low high] where: 0 < low < high < 1. Can be also passed as scalar value, then passed value is set for high threshold, and low is calculated as 0.4 * high
    - sigma - standard deviation of gaussian filter

- function Watershed(file_name, log, open_radius, sharpen_radius, thresh, sigma, gradient_threshold, gaussian_sigma, guassian_filter)

    where:
    - file_name - path to image
    - radius - radius for kernel(in shape of disk) used for morphological opening
    - log - flag indicating that pitures from each step should be saved
    - sharpen_radius - radius of sharpen operation
    - thresh - threshold for Canny detection, it should be vector2d [low high] where: 0 < low < high < 1. Can be also passed as scalar value, then passed value is set for high threshold, and low is calculated as 0.4 * high
    - sigma - standard deviation of gaussian filter, filtering in Canny edge detection
    - gradient_threshold - threshold for gradient filtering, it should be scalar value, for JPG format values should be about 120, but for PNG format it should be about 10 times more
    - gaussian_sigma - standard deviation of gaussian filter
    - guassian_filter -  size of guassian filter, scalar value, should be odd value

Project also contains UI, which simplifies usage of those functions. To use it; run bin_ui.m file in Matlab command window.

All images should be places in Images directory. 

