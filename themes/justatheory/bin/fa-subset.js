// https://github.com/omacranger/fontawesome-subset
const { fontawesomeSubset } = require("fontawesome-subset");
fontawesomeSubset(
    {
        brands: [
            'twitter',
            'mastodon',
            'github',
        ],
        solid: [
            'rss',
            'up-right-from-square',
            'box',
        ],
        regular: [
            'bookmark',
        ],
    },
    '.',
    {
        targetFormats: ['woff', 'woff2']
    }
);
