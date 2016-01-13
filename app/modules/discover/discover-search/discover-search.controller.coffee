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
# File: discover-search.controller.coffee
###

class DiscoverSearchController
    @.$inject = [
        '$routeParams',
        'tgDiscoverProjectsService'
    ]

    constructor: (@routeParams, @discoverProjectsService) ->
        @.page = 1
        @.likeOrder = null
        @.activityOrder = null

        taiga.defineImmutableProperty @, "searchResult", () => return @discoverProjectsService.searchResult
        taiga.defineImmutableProperty @, "nextSearchPage", () => return @discoverProjectsService.nextSearchPage

        @.q = @routeParams.text
        @.filter = @routeParams.filter || 'all'

    fetch: () ->
        return if @.loading

        @discoverProjectsService.resetSearchList()

        @.loading = true

        return @.search().then () =>
            @.loading = false

    showMore: () ->
        return if @.loading

        @.loading = true
        @.page++

        return @.search().then () =>
            @.loading = false

    search: () ->
        filter = @.getFilter()

        params = {
            page: @.page,
            q: @.q,
            likeOrder: @.likeOrder,
            activityOrder: @.activityOrder
        }

        _.assign(params, filter)

        return @discoverProjectsService.fetchSearch(params)

    getFilter: () ->
        if @.filter == 'people'
            return {is_looking_for_people: true}
        else if @.filter == 'scrum'
            return {is_backlog_activated: true}
        else if @.filter == 'kanban'
            return {is_kanban_activated: true}

        return {}

    onChangeFilter: (filter) ->
        @.filter = filter

        @.fetch()

    onChangeOrder: () ->
        @.fetch()

angular.module("taigaDiscover").controller("DiscoverSearch", DiscoverSearchController)
