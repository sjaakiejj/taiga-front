var utils = require('../utils');

var helper = module.exports;

helper.likedProjects = function() {
    return $$('tg-most-liked .highlighted-project');
};

helper.activeProjects = function() {
    return $$('tg-most-active .highlighted-project');
};

helper.featuredProjects = function() {
    return $$('tg-featured-projects .featured-project');
};
