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
# File: discover-projects.service.coffee
###

taiga = @.taiga

class DiscoverProjectsService extends taiga.Service
    @.$inject = [
        "tgResources",
        "tgProjectsService"
    ]

    constructor: (@rs, @projectsService) ->
        @._mostLiked = Immutable.List()
        @._mostActive = Immutable.List()
        @._featured = Immutable.List()
        @._searchResult = Immutable.List()

        @.decorate = @projectsService._decorate.bind(@projectsService)

        taiga.defineImmutableProperty @, "mostLiked", () => return @._mostLiked
        taiga.defineImmutableProperty @, "mostActive", () => return @._mostActive
        taiga.defineImmutableProperty @, "featured", () => return @._featured
        taiga.defineImmutableProperty @, "searchResult", () => return @._searchResult
        taiga.defineImmutableProperty @, "nextSearchPage", () => return @._nextSearchPage

    fetchMostLiked: (params) ->
        return @rs.projects.getProjects(params)
            .then (result) =>
                projects = Immutable.fromJS(result.data)
                projects = projects.map(@decorate)

                @._mostLiked = projects

    fetchMostActive: (params) ->
        return @rs.projects.getProjects(params)
            .then (result) =>
                projects = Immutable.fromJS(result.data)
                projects = projects.map(@decorate)

                @._mostActive = projects

    fetchFeatured: () ->
        return @rs.projects.getProjects()
            .then (result) =>

                projects = Immutable.fromJS(result.data)
                projects = projects.map(@decorate)

                @._featured = projects

    resetSearchList: () ->
        @._searchResult = Immutable.List()

    fetchSearch: (params) ->
        return @rs.projects.getProjects(params)
            .then (result) =>
                @._nextSearchPage = !!result.headers('X-Pagination-Next')

                projects = Immutable.fromJS(result.data)
                projects = projects.map(@decorate)

                @._searchResult = @._searchResult.concat(projects)

angular.module("taigaDiscover").service("tgDiscoverProjectsService", DiscoverProjectsService)
