var utils = require('../utils');
var discoverHelper = require('../helpers/discover-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;


describe('discover', () => {
    before(async () => {
        browser.get(browser.params.glob.host + 'discover');
        await utils.common.waitLoader();
    });

    it('screenshot', async () => {
        await utils.common.takeScreenshot("discover", "discover");
    });

    describe('most liked', () => {
        it('has projects', () => {
            let projects = discoverHelper.likedProjects();

            expect(projects.count()).to.be.eventually.above(0);
        });
    });

    describe('most active', () => {
        it('has projects', () => {
            let projects = discoverHelper.activeProjects();

            expect(projects.count()).to.be.eventually.above(0);
        });
    });

    it('featured projects', () => {
        let projects = discoverHelper.featuredProjects();

        expect(projects.count()).to.be.eventually.above(0);
    });
});
