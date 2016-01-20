###
# Copyright (C) 2014-2016 Jacobus Meulen <jacobus@openbusiness.com.sg>
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
# File: modules/chat/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy
timeout = @.taiga.timeout
bindMethods = @.taiga.bindMethods

module = angular.module("taigaKanban")

# Vars

defaultViewMode = "maximized"
viewModes = [
    "maximized",
    "minimized"
]


#############################################################################
## Kanban Controller
#############################################################################

class ChatController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "$translate",
        "$timeout"
    ]
    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @appMetaService, @navUrls, @events, @analytics, @translate,@timeout, @localStorage) ->

      @scope.unread = {}

      # "slack":"U02R5M2SX"
      # "token":"xoxp-2841671325-2855716915-18901443383-5da2d7da67"
      @userInfo = JSON.parse(localStorage.getItem("userInfo"))

      if !@userInfo.slack_id or !@userInfo.token
        console.error("Not authenticated with slack")

      @api.startRtm().success (res) =>
        connection = new WebSocket(res.url)

        connection.onopen = () =>
          console.log "Opened websocket"
          console.log arguments
          connection.on

        connection.onmessage = (evt) =>
          obj = JSON.parse(evt.data)

          console.log "Received event"
          console.log evt

          #if obj.type is 'message' # and is me
          if obj.type is 'message'
            if obj.channel is @scope.currentChannel
              @scope.channelHistory.unshift(obj)

            else if obj.user isnt @userInfo.slack_id 
              if !@scope.unread[obj.channel]
                @scope.unread[obj.channel] = 0
              @scope.unread[obj.channel] += 1

              console.log("Added to channel")
              console.log(obj.channel)
              console.log(@scope.unread[obj.channel])
              console.log(@scope.unread)
              ###
              channel = @scope.channelList.find (entry) ->
                if entry.id is obj.channel
                  return true
                return false
              ###

          @scope.$apply()
          @timeout () ->
            # Probably need some check here
            element = document.getElementById("mainChatWindow")
            element.scrollTop = element.scrollHeight;



        @api.listChannels().success (res) =>
          console.log res.channels
          @scope.channelList = res.channels;

        @api.listIm().success (res) =>
          console.log res
          @scope.imList = res.ims

        @api.listUsers().success (res) =>
          @scope.memberList = res.members.reduce (res, val) ->
            res[val.id] = val
            return res
          , {}

          console.log @scope.memberList

        @scope.openChannel("C09LCDXT4")

      @scope.sendMessage = (e) =>
        e.preventDefault()
        toSend = @scope.newMessage

        @api.postMessage(@scope.currentChannel, toSend).success (res) =>
          console.log "posted"

        @scope.newMessage = ""

      @scope.openIm = (id) =>
        @api.openIm(id).success (res) =>
          @scope.channelHistory = res.messages
          @scope.currentChannel = id
          @scope.unread[id] = 0
          @scope.$apply()
          @timeout () =>
            element = document.getElementById("mainChatWindow")
            element.scrollTop = element.scrollHeight;

      # By default open the project channel
      @scope.openChannel = (id) =>

        # TODO: Use real time messaging api instead
        @api.openChannel(id).success (res) =>
          @scope.currentChannel = id
          @scope.unread[id] = 0
          @scope.channelHistory = res.messages
          @scope.$apply()
          # After digest
          @timeout () =>
            element = document.getElementById("mainChatWindow")
            element.scrollTop = element.scrollHeight;

      

    openChannel: (id) ->
      console.log("Opening channel")

    # TODO this should be a service
    api: {
        token: @userInfo.token
        base_uri: "http://slack.com/api/"
        listChannels: () ->
          channels = @base_uri + "channels.list?token=#{@token}&exclude_archived=1"
          console.log channels
          return $.ajax(channels)

        listUsers: () ->
          users = @base_uri + "users.list?token=#{@token}"
          return $.ajax(users)

        listIm: () ->
          ims = @base_uri + "im.list?token=#{@token}"
          return $.ajax(ims)

        startRtm: () ->
          rtm = @base_uri + "rtm.start?token=#{@token}"
          return $.ajax(rtm)

        openIm: (id) ->
          channel = @base_uri + "im.history?token=#{@token}&channel=#{id}"
          return $.ajax(channel)

        openChannel: (id) ->
          channel = @base_uri + "channels.history?token=#{@token}&channel=#{id}"
          return $.ajax(channel)

        testAuth: () ->
          auth = @base_uri + "auth.test?token=#{@token}"
          return $.ajax(auth)

        postMessage: (channel, message) ->
          url = @base_uri + "chat.postMessage"
          return $.post(url,{
            token: @token
            channel: channel
            text: message
            as_user: true
          })

      }
module.controller("ChatController", ChatController)

#############################################################################
## Chat Filters
#############################################################################

module.filter("messageParser", () ->
  fetchUserDisplay = (toReplace, userList) ->
    if toReplace.indexOf("|") >= 0
      return toReplace.substring(toReplace.indexOf("|") + 1, toReplace.length - 1)
    else
      return userList[toReplace.substring(2,toReplace.length-1)].name || toReplace.substring(2,toReplace.length-1)

  parseTag = (tag, userList, channelList) ->
    # We have a few types:
    # 1) URL (Starts with 'http')
    # 2) Channel (Starts with #)
    # 3) User (Starts with @)
    
    # User
    if tag.indexOf("http") >= 0
      prefix = "&lt;a target='_blank' href='#{tag.substring(1,tag.length-1)}'&gt;"
      displayStr = tag.substring(1,tag.length-1)
      suffix = "&lt;/a&gt;"
    else if tag.indexOf("@") >= 0
      prefix = "&lt;strong&gt;&lt;a style='font-weight: bold;' ng-click=''&gt;@"
      displayStr = fetchUserDisplay(tag,userList)
      suffix = "&lt;/a&gt;&lt;/strong&gt;"
    else if tag.indexOf("#") >= 0
      prefix = "&lt;strong&gt;&lt;a ng-click=''&gt;#"
      displayStr = tag
      suffix = "&lt;/a&gt;&lt;/strong&gt;"
    # Now lets see if we've got a display string included
    return "#{prefix}#{displayStr}#{suffix}"


  return (message, userList, channelList) ->
    while (start = message.search(/(<)[^>]*>/)) >= 0
      end = message.substring(start,message.length).search(/>/) + start + 1
      toReplace = message.substring(start,end)
      # We should note that these are also associated with view properties.
      message = message.replace(toReplace, parseTag(toReplace, userList))



    # TODO: Should also substitute formatting

    return message.replace(/&gt;/gi, ">").replace(/&lt;/gi, "<")
)
