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
# File: most-liked.controller.spec.coffee
###

describe "MostLiked", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockDiscoverProjectsService = ->
        mocks.discoverProjectsService = {
            fetchMostLiked: sinon.stub()
        }

        $provide.value("tgDiscoverProjectsService", mocks.discoverProjectsService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockDiscoverProjectsService()

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

    it "fetch", () ->
        ctrl = $controller("MostLiked")

        ctrl.getOrderBy = sinon.stub().returns('order1')

        ctrl.fetch()

        expect(mocks.discoverProjectsService.fetchMostLiked).to.have.been.calledWith(sinon.match({order_by: 'order1'}))

    it "order by", () ->
        promise = mocks.discoverProjectsService.fetchMostLiked.withArgs(sinon.match({order_by: 'order1'})).promise()

        ctrl = $controller("MostLiked")

        ctrl.getOrderBy = sinon.stub().returns('order1')

        ctrl.orderBy('type1').then () ->
            expect(ctrl.loading).to.be.false

        expect(ctrl.loading).to.be.true
        expect(ctrl.currentOrderBy).to.be.equal('type1')

        promise.resolve()

    it "get order by", () ->
        ctrl = $controller("MostLiked")

        ctrl.currentOrderBy = 'all'

        orderBy = ctrl.getOrderBy()

        expect(orderBy).to.be.equal('-total_fans')

        ctrl.currentOrderBy = 'other'

        orderBy = ctrl.getOrderBy()
        expect(orderBy).to.be.equal('-total_fans_last_other')
