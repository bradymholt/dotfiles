const got = require('got');
const tempfile = require('tempfile');
const wallpaper = require('wallpaper');
const path = require('path');
const fs = require('fs');
const request = require("request")

function setWallpaper(url) {
    const file = tempfile(path.extname(url));

    got
        .stream(url)
        .pipe(fs.createWriteStream(file))
        .on('finish', () => {
            wallpaper.set(file);
        });
}

function setBing() {
    request({
        url: "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US",
        json: true
    }, function (error, response, body) {

        if (!error && response.statusCode === 200) {
            setWallpaper("http://www.bing.com" + body.images[0].url);
        }
    });
}

function setUnsplash() {
    var api_key = process.env.UNSPLASH_API_KEY;

    request({
        url: "https://api.unsplash.com/photos/random?client_id=" + api_key,
        json: true
    }, function (error, response, body) {

        if (!error && response.statusCode === 200) {
            setWallpaper(body.urls.full);
        }
    })
}

function setChromecast() {
    request({
        url: "https://raw.githubusercontent.com/mattburns/chromecast-backgrounds/master/backgrounds.json",
        json: true
    }, function (error, response, body) {

        if (!error && response.statusCode === 200) {
            var randomPhoto = body[Math.floor(Math.random()*body.length)]; 
            setWallpaper(randomPhoto.url);
        }
    });
}

function setGooglePhoto() {
    request({
        url: "https://picasaweb.google.com/data/feed/base/user/108862440783718909111/albumid/6217521077777661025?alt=json&kind=photo&max-results=100&hl=en_US&imgmax=1600",
        json: true
    }, function (error, response, body) {

        if (!error && response.statusCode === 200) {
            var randomPhoto = body.feed.entry[Math.floor(Math.random()*body.feed.entry.length)];
            setWallpaper(randomPhoto.content.src);
        }
    });
}

//setBing();
//setUnsplash();
setChromecast();
//setGooglePhoto();
