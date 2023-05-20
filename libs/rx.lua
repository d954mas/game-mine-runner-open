-- RxLua v0.0.3
-- https://github.com/bjornbytes/rxlua
-- MIT License

local Class = require "libs.middleclass"

local util = {}

util.pack = table.pack or function(...) return { n = select('#', ...), ... } end
util.unpack = table.unpack or unpack
util.eq = function(x, y) return x == y end
util.noop = function() end
util.identity = function(x) return x end
util.constant = function(x) return function() return x end end
util.isa = function(object, class)
	return type(object) == 'table' and object:isInstanceOf(class)
end
util.tryWithObserver = function(observer, fn, ...)
	local success, result = pcall(fn, ...)
	if not success then
		observer:onError(result)
	end
	return success, result
end

--A handle representing the link between an Observer and an Observable, as well as any
--work required to clean up after the Observable completes or the Observer unsubscribes.
---@class Subscription
local Subscription = Class.class("Subsription")

---Creates a new Subscription.
---@param action function action function  The action to run when the subscription is unsubscribed. It will only be run once.
---@return Subscription
function Subscription:initialize(action)
	self.action = action
	self.unsubscribed = false
end

function Subscription.create(action)
	return Subscription(action)
end

--- Unsubscribes the subscription, performing any necessary cleanup work.
function Subscription:unsubscribe()
	if self.unsubscribed then return end
	self.action(self)
	self.unsubscribed = true
end

local CompositeSubscription = Class.class("CompositeSubscription")

--- Unsubscribes the subscription, performing any necessary cleanup work.
function CompositeSubscription:unsubscribe()
	for _, s in ipairs(self.subscriptions) do
		s:unsubscribe()
	end
	self.subscriptions = {}
end

---@param subscription Subscription
function CompositeSubscription:add(subscription)
	table.insert(self.subscriptions,subscription)
end

function CompositeSubscription:initialize()
	self.subscriptions = {}
end


--- @class Observer
---  Observers are simple objects that receive values from Observables.
local Observer = Class.class("Observer")

--- Creates a new Observer.
----@param onNext function Called when the Observable produces a value.
----@param onError function Called when the Observable terminates due to an error.
----@param onCompleted function Called when the Observable completes normally.
---@return Observer
function Observer:initialize(onNext, onError, onCompleted)
	self._onNext = onNext or util.noop
	self._onError = onError or error
	self._onCompleted = onCompleted or util.noop
	self.stopped = false
end

function Observer.create(onNext, onError, onCompleted)
	return Observer(onNext, onError, onCompleted)
end

--- Pushes zero or more values to the Observer.
---@vararg any
function Observer:onNext(...)
	if not self.stopped then
		self._onNext(...)
	end
end

--- Notify the Observer that an error has occurred.
---@param message string A string describing what went wrong.
function Observer:onError(message)
	if not self.stopped then
		self.stopped = true
		self._onError(message)
	end
end

--- Notify the Observer that the sequence has completed and will produce no more values.
function Observer:onCompleted()
	if not self.stopped then
		self.stopped = true
		self._onCompleted()
	end
end

--  Observables push values to Observers.
--- @class Observable
local Observable = Class.class("Observable")

--- Creates a new Observable.
---@param subscribe function The subscription function that produces values.
---@return Observable
function Observable:initialize(subscribe)
	self._subscribe = subscribe
end

function Observable.create(subscribe)
	return Observable(subscribe)
end


--- Shorthand for creating an Observer and passing it to this Observable's subscription function.
---@param onNext function Called when the Observable produces a value.
---@param onError function Called when the Observable terminates due to an error.
---@param onCompleted function Called when the Observable completes normally.
---@return Subscription
function Observable:subscribe(onNext, onError, onCompleted)
	if type(onNext) == 'table' then
		return self._subscribe(onNext)
	else
		return self._subscribe(Observer.create(onNext, onError, onCompleted))
	end
end


---Returns an Observable that buffers values from the original and produces them as multiple values.
---@param size number  The size of the buffer.
function Observable:buffer(size)
	return Observable.create(function(observer)
		local buffer = {}

		local function emit()
			if #buffer > 0 then
				observer:onNext(util.unpack(buffer))
				buffer = {}
			end
		end

		local function onNext(...)
			local values = {...}
			for i = 1, #values do
				table.insert(buffer, values[i])
				if #buffer >= size then
					emit()
				end
			end
		end

		local function onError(message)
			emit()
			return observer:onError(message)
		end

		local function onCompleted()
			emit()
			return observer:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end



--- Returns a new Observable that produces the values of the original delayed by a time period.
---@param time number|function time An amount in milliseconds to delay by, or a function which returns this value.
---@param scheduler Scheduler The scheduler to run the Observable on.
---@return Observable
function Observable:delay(time, scheduler)
	assert(scheduler)
	time = type(time) ~= 'function' and util.constant(time) or time

	return Observable.create(function(observer)
		local actions = {}

		local function delay(key)
			return function(...)
				local arg = util.pack(...)
				local handle = scheduler:schedule(function()
					observer[key](observer, util.unpack(arg))
				end, time())
				table.insert(actions, handle)
			end
		end

		local subscription = self:subscribe(delay('onNext'), delay('onError'), delay('onCompleted'))

		return Subscription.create(function()
			if subscription then subscription:unsubscribe() end
			for i = 1, #actions do
				actions[i]:unsubscribe()
			end
		end)
	end)
end

--- Returns a new Observable that produces the values from the original with duplicates removed.
---@return Observable
function Observable:distinct()
	return Observable.create(function(observer)
		local values = {}

		local function onNext(x)
			if not values[x] then
				observer:onNext(x)
			end

			values[x] = true
		end

		local function onError(e)
			return observer:onError(e)
		end

		local function onCompleted()
			return observer:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end
---call observer in go context. Used sheduler
---@return Observable
function Observable:go(scheduler)
	return self:delay(0,scheduler)
end

---@param scheduler Scheduler
---@return Observable
function Observable:go_distinct(scheduler)
	local values = {}
	local need_clean = false --clean only if it have values
	local o1 = Observable.create(function(observer)
		local function onNext(x)
			if not values[x == nil and "nil" or x] then
				need_clean = true
				values[x == nil and "nil" or x] = true
				observer:onNext(x)
			end
		end
		local function onError(e)
			return observer:onError(e)
		end
		local function onCompleted()
			return observer:onCompleted()
		end
		return self:subscribe(onNext, onError, onCompleted)
	end):delay(0,scheduler)

	return o1.create(function(observer)
		local function onNext(x)
			if need_clean then
				values = {}
			end
			observer:onNext(x)
		end
		local function onError(e)
			return observer:onError(e)
		end
		local function onCompleted()
			return observer:onCompleted()
		end
		return o1:subscribe(onNext, onError, onCompleted)
	end)
end


--- Returns a new Observable that only produces values of the first that satisfy a predicate.
---@param predicate function  The predicate used to filter values.
---@return Observable
function Observable:filter(predicate)
	predicate = predicate or util.identity

	return Observable.create(function(observer)
		local function onNext(...)
			util.tryWithObserver(observer, function(...)
				if predicate(...) then
					return observer:onNext(...)
				end
			end, ...)
		end

		local function onError(e)
			return observer:onError(e)
		end

		local function onCompleted()
			return observer:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end


--- @class CooperativeScheduler:Scheduler
---  Manages Observables using coroutines and a virtual clock that must be updated
--- manually.
local CooperativeScheduler = {}
CooperativeScheduler.__index = CooperativeScheduler
CooperativeScheduler.__tostring = util.constant('CooperativeScheduler')

--- Creates a new CooperativeScheduler.
---@param  currentTime number|nil currentTime A time to start the scheduler at.
---@return CooperativeScheduler
function CooperativeScheduler.create(currentTime)
	local self = {
		tasks = {},
		currentTime = currentTime or 0
	}

	return setmetatable(self, CooperativeScheduler)
end

--- Schedules a function to be run after an optional delay.  Returns a subscription that will stop
--- the action from running.
---@param action function  The function to execute. Will be converted into a coroutine. The
---                          coroutine may yield execution back to the scheduler with an optional
---                          number, which will put it to sleep for a time period.
---@param delay number|nil  Delay execution of the action by a virtual time period.
---@return Subscription
function CooperativeScheduler:schedule(action, delay)
	local task = {
		thread = coroutine.create(action),
		due = self.currentTime + (delay or 0)
	}

	table.insert(self.tasks, task)

	return Subscription.create(function()
		return self:unschedule(task)
	end)
end

function CooperativeScheduler:unschedule(task)
	for i = 1, #self.tasks do
		if self.tasks[i] == task then
			table.remove(self.tasks, i)
		end
	end
end

--- Triggers an update of the CooperativeScheduler. The clock will be advanced and the scheduler
--- will run any coroutines that are due to be run.
---@param delta number|nil  An amount of time to advance the clock by. It is common to pass in the
---                         time in seconds or milliseconds elapsed since this function was last
---                         called.
function CooperativeScheduler:update(delta)
	self.currentTime = self.currentTime + (delta or 0)

	local i = 1
	while i <= #self.tasks do
		local task = self.tasks[i]

		if self.currentTime >= task.due then
			local success, delay = coroutine.resume(task.thread)

			if coroutine.status(task.thread) == 'dead' then
				table.remove(self.tasks, i)
			else
				task.due = math.max(task.due + (delay or 0), self.currentTime)
				i = i + 1
			end

			if not success then
				error(debug.traceback(task.thread,"Error in coroutine:" .. tostring(delay) ,1))
			end
		else
			i = i + 1
		end
	end
end

--- Returns whether or not the CooperativeScheduler's queue is empty.
function CooperativeScheduler:isEmpty()
	return not next(self.tasks)
end


--Subjects function both as an Observer and as an Observable. Subjects inherit all
--Observable functions, including subscribe. Values can also be pushed to the Subject, which will
--be broadcasted to any subscribed Observers.
---@class Subject:Observable
local Subject = Class.class("Subject",Observable)

--- Creates a new Subject.
---@return Subject
function Subject:initialize()
	self.observers = {}
	self.stopped = false
end

function Subject.create()
	return Subject()
end




--- Creates a new Observer and attaches it to the Subject.
---@param onNext function|Observer A function called when the Subject produces a value or
---                                         an existing Observer to attach to the Subject.
---@param onError function  Called when the Subject terminates due to an error.
---@param onCompleted function  Called when the Subject completes normally.
function Subject:subscribe(onNext, onError, onCompleted)
	local observer

	if util.isa(onNext, Observer) then
		observer = onNext
	else
		observer = Observer.create(onNext, onError, onCompleted)
	end


	table.insert(self.observers, observer)

	return Subscription.create(function()
		for i = 1, #self.observers do
			if self.observers[i] == observer then
				table.remove(self.observers, i)
				return
			end
		end
	end)
end

--- Pushes zero or more values to the Subject. They will be broadcasted to all Observers.
---@vararg any
function Subject:onNext(...)
	if not self.stopped then
		for i = #self.observers, 1, -1 do
			self.observers[i]:onNext(...)
		end
	end
end

--- Signal to all Observers that an error has occurred.
---@param message string  A string describing what went wrong.
function Subject:onError(message)
	if not self.stopped then
		for i = #self.observers, 1, -1 do
			self.observers[i]:onError(message)
		end
		self.stopped = true
	end
end

--- Signal to all Observers that the Subject will not produce any more values.
function Subject:onCompleted()
	if not self.stopped then
		for i = #self.observers, 1, -1 do
			self.observers[i]:onCompleted()
		end

		self.stopped = true
	end
end

Subject.__call = Subject.onNext


local SubscriptionsStorage = Class("SubscriptionsStorage")

function SubscriptionsStorage:initialize()
	self.subscriptions = {}
end

function SubscriptionsStorage:add(subscription)
	assert(subscription)
	assert(subscription.unsubscribe)
	table.insert(self.subscriptions, subscription)
end

function SubscriptionsStorage:unsubscribe()
	for _, subscription in ipairs(self.subscriptions) do
		subscription:unsubscribe()
	end
	self.subscriptions = {}
end



return {
	util = util,
	Subscription = Subscription,
	Observer = Observer,
	Observable = Observable,
	CooperativeScheduler = CooperativeScheduler,
	Subject = Subject,
	MainScheduler = CooperativeScheduler.create(), -- Application thread.update in bootstrap collection.
	SubscriptionsStorage = SubscriptionsStorage,
}