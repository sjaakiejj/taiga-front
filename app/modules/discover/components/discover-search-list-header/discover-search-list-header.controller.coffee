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
# File: discover-search-list-header.controller.coffee
###

class DiscoverSearchListHeaderController
    @.$inject = []

    constructor: () ->
        @.like_is_open = @.orderBy.indexOf('-total_fans') == 0
        @.activity_is_open = @.orderBy.indexOf('-total_activity') == 0

    toggleOpenLike: () ->
        @.like_is_open = !@.like_is_open

        if @.like_is_open
            @.activity_is_open = false

    toggleOpenActivity: () ->
        @.activity_is_open = !@.activity_is_open

        if @.activity_is_open
            @.like_is_open = false

    setOrderBy: (type = '') ->
        @.onChange({orderBy: type})

angular.module("taigaDiscover").controller("DiscoverSearchListHeader", DiscoverSearchListHeaderController)
