###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: discover-search.controller.spec.coffee
###

describe "DiscoverSearch", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockRouteParams = ->
        mocks.routeParams = {}

        $provide.value("$routeParams", mocks.routeParams)

    _mockDiscoverProjects = ->
        mocks.discoverProjects = {
            resetSearchList: sinon.spy(),
            fetchSearch: sinon.stub()
        }

        mocks.discoverProjects.fetchSearch.promise().resolve()

        $provide.value("tgDiscoverProjectsService", mocks.discoverProjects)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockRouteParams()
            _mockDiscoverProjects()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _setup()

    it "initialize search params", () ->
        mocks.routeParams.text = 'text'
        mocks.routeParams.filter = 'filter'

        ctrl = $controller('DiscoverSearch')

        expect(ctrl.q).to.be.equal('text')
        expect(ctrl.filter).to.be.equal('filter')

    it "fetch", (done) ->
        ctrl = $controller('DiscoverSearch')

        ctrl.search = sinon.stub().promise()

        ctrl.fetch().then () ->
            expect(ctrl.loading).to.be.false

            done()

        expect(ctrl.loading).to.be.true
        expect(mocks.discoverProjects.resetSearchList).to.have.been.called
        expect(ctrl.search).to.have.been.called

        ctrl.search.resolve()

    it "showMore", (done) ->
        ctrl = $controller('DiscoverSearch')

        ctrl.search = sinon.stub().promise()

        ctrl.showMore().then () ->
            expect(ctrl.loading).to.be.false

            done()

        expect(ctrl.loading).to.be.true
        expect(ctrl.search).to.have.been.called
        expect(ctrl.page).to.be.equal(2)

        ctrl.search.resolve()

    it "search", () ->
        mocks.discoverProjects.fetchSearch = sinon.stub()

        filter = {
            filter: '123'
        }

        ctrl = $controller('DiscoverSearch')

        ctrl.page = 1
        ctrl.q = 'text'
        ctrl.likeOrder = 1
        ctrl.activityOrder = 1

        ctrl.getFilter = () -> return filter

        params = {
            q: 123,
            page: 1,
            q: 'text',
            likeOrder: 1,
            activityOrder: 1
        }

        ctrl.search()

        expect(mocks.discoverProjects.fetchSearch).have.been.calledWith(sinon.match(params))

    it "get filter", () ->
        ctrl = $controller('DiscoverSearch')

        ctrl.filter = 'people'
        expect(ctrl.getFilter()).to.be.eql({is_looking_for_people: true})

        ctrl.filter = 'scrum'
        expect(ctrl.getFilter()).to.be.eql({is_backlog_activated: true})

        ctrl.filter = 'kanban'
        expect(ctrl.getFilter()).to.be.eql({is_kanban_activated: true})
