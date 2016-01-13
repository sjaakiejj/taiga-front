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
# File: discover-home-order-by.controller.spec.coffee
###

describe.only "DiscoverSearchListHeader", ->
    $provide = null
    $controller = null
    scope = null

    _inject = ->
        inject (_$controller_, $rootScope) ->
            $controller = _$controller_
            scope = $rootScope.$new()

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _setup()

    it "toggleOpenLike", () ->
        ctrl = $controller("DiscoverSearchListHeader")

        ctrl.toggleOpenLike()

        expect(ctrl.like_is_open).to.be.true
        expect(ctrl.activity_is_open).to.be.false

        ctrl.toggleOpenLike()

        expect(ctrl.like_is_open).to.be.false

    it "toggleOpenActivity", () ->
        ctrl = $controller("DiscoverSearchListHeader")

        ctrl.toggleOpenActivity()

        expect(ctrl.activity_is_open).to.be.true
        expect(ctrl.like_is_open).to.be.false

        ctrl.toggleOpenActivity()

        expect(ctrl.activity_is_open).to.be.false

    it "likeOrderBy", () ->
        ctrl = $controller("DiscoverSearchListHeader")

        ctrl.onChange = sinon.spy()

        ctrl.likeOrderBy("type1")

        expect(ctrl.likeOrder).to.be.equal('type1')
        expect(ctrl.activityOrder).to.be.null
        expect(ctrl.onChange).to.be.called

    it "activityOrderBy", () ->
        ctrl = $controller("DiscoverSearchListHeader")

        ctrl.onChange = sinon.spy()

        ctrl.activityOrderBy("type1")

        expect(ctrl.activityOrder).to.be.equal('type1')
        expect(ctrl.likeOrder).to.be.null
        expect(ctrl.onChange).to.be.called
