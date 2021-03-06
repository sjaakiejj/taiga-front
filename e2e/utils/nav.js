var helper = module.exports;

var common = require('./common');

var actions = {
    project: function(index) {
        browser.actions().mouseMove($('div[tg-dropdown-project-list]')).perform();

        let project = null;

        if (typeof index === 'string' || index instanceof String) {
            project = $('div[tg-dropdown-project-list]').element(by.cssContainingText('li a', index));
        } else {
            project = $$('div[tg-dropdown-project-list] li a').get(index);
        }

        common.link(project);

        return common.waitLoader();
    },
    issues: function(index) {
        common.link($('#nav-issues a'));

        return common.waitLoader();
    },
    issue: function(index) {
        let issue = $$('section.issues-table .row.table-main .subject a').get(index);

        common.link(issue);

        return common.waitLoader();
    },
    backlog: function() {
        common.link($('#nav-backlog a'));

        return common.waitLoader();
    },
    us: function(index) {
        let us = $$('.user-story-name>a').get(index);

        common.link(us);

        return common.waitLoader();
    },
    home: function() {
        browser.get(browser.params.glob.host);
        return common.waitLoader();
    },
    taskboard: function(index) {
        let link = $$('.sprints .button-gray').get(index);

        common.link(link);

        return common.waitLoader();
    },
    task: function(index) {
        common.link($$('div[tg-taskboard-task] a.task-name').get(index));

        return common.waitLoader();
    }
};

var nav = {
    project: function(index) {
        this.actions.push(actions.project.bind(null, index));
        return this;
    },
    issues: function() {
        this.actions.push(actions.issues);
        return this;
    },
    issue: function(index) {
        this.actions.push(actions.issue.bind(null, index));
        return this;
    },
    backlog: function(index) {
        this.actions.push(actions.backlog.bind(null, index));
        return this;
    },
    us: function(index) {
        this.actions.push(actions.us.bind(null, index));
        return this;
    },
    home: function() {
        this.actions.push(actions.home.bind(null));
        return this;
    },
    taskboard: function(index) {
        this.actions.push(actions.taskboard.bind(null, index));
        return this;
    },
    task: function(index) {
        this.actions.push(actions.task.bind(null, index));
        return this;
    },
    go: function() {
        let promise = this.actions[0]();

        for (let i = 1; i < this.actions.length; i++) {
            promise = promise.then(this.actions[i]);
        }

        return promise;
    }
};

helper.init = function() {
    let newNav = Object.create(nav);
    newNav.actions = [];

    return newNav;
};
