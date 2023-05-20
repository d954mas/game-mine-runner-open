local COMMON = require "libs.common"
local CONSTANTS = require "libs.constants"
local SM = require "libs_project.sm"
local WORLD = require("world.world")

local QUAT_SHOP_MODEL = vmath.quat_rotation_x(math.rad(0))

local Render = COMMON.class("Base3dRender")

local render3d = require("scene3d.render.render3d")

function Render:init()
	self.predicates = {
		-- GUI predicates
		gui = render.predicate({ "gui" }),
		vignete = render.predicate({ "vignete" }),
		vdrop = render.predicate({ "vdrop" }),
		gui_shop_skin_text = render.predicate({ "gui_shop_skin_text" }),
		text = render.predicate({ "text" }),

		-- Non-opaque sprites & particles predicates
		tile = render.predicate({ "tile" }),
		particle = render.predicate({ "particle" }),

		-- 3D predicates
		model = render.predicate({ "model" }),
		gem = render.predicate({ "gem" }),
		powerup = render.predicate({ "powerup" }),
		glow_gem = render.predicate({ "glow_gem" }),
		glow_player = render.predicate({ "glow_player" }),
		glow_acceleration_arrow = render.predicate({ "glow_acceleration_arrow" }),
		shine_player = render.predicate({ "shine_player" }),
		acceleration_arrow = render.predicate({ "acceleration_arrow" }),
		box = render.predicate({ "box" }),
		box_column = render.predicate({ "box_column" }),
		--	vagon = render.predicate({ "vagon" }),
		skin_shop = render.predicate({ "skin_shop" }),
		-- Other predicates
		sky = render.predicate({ "sky" }),
		earth = render.predicate({ "earth" })
	}
	self.clear_color = vmath.vector4(0.07, 0.07, 0.07, 1)
	self.clear = {
		[render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0
	}
	self.clear_depth = {
		[render.BUFFER_DEPTH_BIT] = 1
	}
	--самый первый размер это размер игры. Иначе камеры плохо отрабатывыют в html  билде
	self.screen_size = {
		w = CONSTANTS.PLATFORM_IS_WEB and render.get_width() or render.get_window_width(),
		h = CONSTANTS.PLATFORM_IS_WEB and render.get_height() or render.get_window_height(),
	}

	self.draw_opts = {
		constants = render.constant_buffer(),
		frustum = nil,
	}
	self.draw_opts_gems = {
		constants = render.constant_buffer(),
		frustum = nil,
	}
	self.draw_opts_arrow = {
		constants = render.constant_buffer(),
		frustum = nil,
	}
	self.draw_opts_player = {
		constants = render.constant_buffer(),
		frustum = nil,
	}
	self.draw_opts_obstacles = {
		constants = render.constant_buffer(),
		frustum = nil,
	}
	self.draw_opts.constants.light_ambient = vmath.vector4(1)
	self.draw_opts.constants.light_directional = vmath.vector4(1)
	self.draw_opts.constants.fog = vmath.vector4(1)
	self.draw_opts.constants.fog_color = vmath.vector4(1)
	self:init_directional_light()

	self:window_size_changed()
end

function Render:window_size_changed()
	self.screen_size.w = math.max(1, render.get_window_width())
	self.screen_size.h = math.max(1, render.get_window_height())
	render3d.update_window(self.screen_size.w, self.screen_size.h)
	self.gui_proj = vmath.matrix4_orthographic(0, self.screen_size.w, 0, self.screen_size.h, -1000, 1000)
	self.empty_view = vmath.matrix4()
	self.vignete_proj = vmath.matrix4_orthographic(-0.5,0.5,-0.5,0.5, -1, 1)
	self.render3d_perspective = nil


end

function Render:render_postprocess()
	render.set_view(self.empty_view)
	render.set_projection(self.vignete_proj)

	render.set_depth_mask(false)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_STENCIL_TEST)
	render.disable_state(render.STATE_CULL_FACE)
	render.enable_state(render.STATE_BLEND)
	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)
	render.draw(self.predicates.vdrop)
	render.draw(self.predicates.vignete)
end

function Render:get_3d_perspective()
	if (not self.render3d_perspective or render3d.perspective_dirty) then
		self.render3d_perspective = render3d.camera_perspective()
	end
	return self.render3d_perspective
end

function Render:init_directional_light()
	local light_rotation = vmath.quat_rotation_x(math.rad(-120))
	render3d.light_directional_direction = vmath.rotate(light_rotation, render3d.FORWARD)
	local def = WORLD.storage.game:world_id_def_get()
	render3d.light_ambient_color = vmath.vector3(1, 1, 1)
	render3d.light_ambient_intensity = def.light_ambient_intensity or 0.5
	render3d.light_directional_intensity = def.light_directional_intensity or 0.5
	render3d.light_dirty = true

	render3d.fog_intensity = 0.9
	render3d.fog_range_from = 20
	render3d.fog_range_to = 50
	render3d.fog_color = vmath.vector3(0.07, 0.07, 0.07)
	render3d.fog_dirty = true
end

function Render:update()
	local window_width = self.screen_size.w
	local window_height = self.screen_size.h

	if (render3d.light_dirty) then
		render3d.light_dirty = false
		local color = render3d.light_ambient_color
		local intensity = render3d.light_ambient_intensity
		self.draw_opts.constants.light_ambient = vmath.vector4(color.x, color.y, color.z, intensity)
		self.draw_opts_gems.constants.light_ambient = vmath.vector4(color.x, color.y, color.z, intensity)
		self.draw_opts_arrow.constants.light_ambient = vmath.vector4(1, 1, 1, 0.6)
		self.draw_opts_obstacles.constants.light_ambient = vmath.vector4(color.x, color.y, color.z, intensity)

		local dir = render3d.light_directional_direction
		intensity = render3d.light_directional_intensity
		self.draw_opts.constants.light_directional = vmath.vector4(-dir.x, -dir.y, -dir.z, intensity)
		self.draw_opts_gems.constants.light_directional = vmath.vector4(dir.x, dir.y, dir.z, 0.5)
		self.draw_opts_arrow.constants.light_directional = vmath.vector4(dir.x, dir.y, dir.z, 0.15)
		self.draw_opts_obstacles.constants.light_directional = vmath.vector4(-dir.x, -dir.y, -dir.z, intensity)
		local dir_player = vmath.vector3(0, 1, 1)
		xmath.normalize(dir_player, dir_player)
		self.draw_opts_player.constants.light_directional = vmath.vector4(dir_player.x, dir_player.y, dir_player.z, 0.2)
		self.draw_opts_player.constants.light_ambient = vmath.vector4(1, 1, 1, 0.65)
	end

	if (render3d.fog_dirty) then
		render3d.fog_dirty = false
		self.draw_opts.constants.fog = vmath.vector4(render3d.fog_range_from, render3d.fog_range_to, 0, render3d.fog_intensity)
		self.draw_opts.constants.fog_color = vmath.vector4(render3d.fog_color.x, render3d.fog_color.y, render3d.fog_color.z, 1.0)

		self.draw_opts_obstacles.constants.fog = vmath.vector4(30, 75, 0, 0.8)
		self.draw_opts_obstacles.constants.fog_color = vmath.vector4(render3d.fog_color.x, render3d.fog_color.y, render3d.fog_color.z, 1.0)

		self.draw_opts_gems.constants.fog = vmath.vector4(render3d.fog_range_from, render3d.fog_range_to, 0, render3d.fog_intensity)
		self.draw_opts_gems.constants.fog_color = vmath.vector4(render3d.fog_color.x, render3d.fog_color.y, render3d.fog_color.z, 1.0)

		self.draw_opts_arrow.constants.fog = vmath.vector4(render3d.fog_range_from, render3d.fog_range_to, 0, render3d.fog_intensity)
		self.draw_opts_arrow.constants.fog_color = vmath.vector4(render3d.fog_color.x, render3d.fog_color.y, render3d.fog_color.z, 1.0)

		self.draw_opts_player.constants.fog = vmath.vector4(render3d.fog_range_from, render3d.fog_range_to, 0, render3d.fog_intensity)
		self.draw_opts_player.constants.fog_color = vmath.vector4(render3d.fog_color.x, render3d.fog_color.y, render3d.fog_color.z, 1.0)
	end

	render.set_depth_mask(true)
	render.set_stencil_mask(0xff)
	-- Perform a clear on a framebuffer’s contents to avoid fetching the previous frame’s data on tile-based
	-- graphics architectures, which reduces memory bandwidth.
	-- (https://docs.imgtec.com/Architecture_Guides/PowerVR_Architecture/topics/rules/c_GoldenRules_do_perform_clear.html)
	render.clear(self.clear)

	render.set_viewport(0, 0, window_width, window_height)

	-- Opaque
	local mat_view = render3d.camera_view()
	render.set_view(mat_view)
	local mat_proj = self:get_3d_perspective()
	render.set_projection(mat_proj)
	--	local mat_frustum = render3d.camera_perspective() * mat_view
	--	scene3d.frustum_set(mat_frustum)
	--	self.draw_opts.frustum = mat_frustum

	--render.set_depth_mask(true)
	render.enable_state(render.STATE_DEPTH_TEST)
	render.enable_state(render.STATE_CULL_FACE)
	render.disable_state(render.STATE_STENCIL_TEST)
	render.disable_state(render.STATE_BLEND)

	render.draw(self.predicates.earth, self.draw_opts)

	render.set_depth_mask(false)
	render.enable_state(render.STATE_BLEND)
	render.disable_state(render.STATE_CULL_FACE)
	render.draw(self.predicates.glow_player, self.draw_opts)
	render.set_depth_mask(true)
	render.disable_state(render.STATE_BLEND)
	render.enable_state(render.STATE_CULL_FACE)

	render.draw(self.predicates.model, self.draw_opts_player)

	if (COMMON.CONSTANTS.VERSION_IS_DEV) then
		render.draw_debug3d()
	end

	-- Non-opaque, i.e. alpha-blended sprites
	render.enable_state(render.STATE_BLEND)
	--render.set_projection(mat_proj)
	render.set_blend_func(render.BLEND_ONE, render.BLEND_ONE_MINUS_SRC_ALPHA)

	--render.set_depth_mask(true)
	--render.draw(self.predicates.vagon, self.draw_opts)
	render.draw(self.predicates.box, self.draw_opts_obstacles)
	render.draw(self.predicates.box_column, self.draw_opts_obstacles)


	render.set_depth_mask(false)
	render.disable_state(render.STATE_CULL_FACE)

	render.draw(self.predicates.glow_gem, self.draw_opts)
	render.draw(self.predicates.glow_acceleration_arrow, self.draw_opts)

	render.set_depth_mask(true)
	--	render.enable_state(render.STATE_DEPTH_TEST)
	render.enable_state(render.STATE_CULL_FACE)
	--render.disable_state(render.STATE_STENCIL_TEST)
	render.disable_state(render.STATE_BLEND)
	render.draw(self.predicates.gem, self.draw_opts_gems)
	render.draw(self.predicates.powerup, self.draw_opts_gems)
	render.draw(self.predicates.acceleration_arrow, self.draw_opts_arrow)

	render.set_depth_mask(false)
	render.enable_state(render.STATE_BLEND)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_CULL_FACE)
	render.draw(self.predicates.shine_player)




	--	render.draw(self.predicates.particle, self.draw_opts)

	--self:render_postprocess()
	-- Render GUI. It takes the whole screen at this moment.
	render3d.update_window(window_width, window_height)

	render.set_view(self.empty_view)
	render.set_projection(self.gui_proj)

	render.disable_state(render.STATE_DEPTH_TEST)
	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(self.predicates.gui)
	render.draw(self.predicates.text)
	render.disable_state(render.STATE_STENCIL_TEST)

	if SM:is_working() or (SM:get_top() and SM:get_top()._name == SM.MODALS.SHOP) then
		render3d.view_from_rotation(QUAT_SHOP_MODEL)
		render3d.view_position = vmath.vector3(0, 0, 0)
		mat_view = render3d.camera_view()
		mat_proj = render3d.camera_perspective(math.rad(50))
		render.set_view(mat_view)
		render.set_projection(mat_proj)

		render.set_depth_mask(true)
		render.clear(self.clear_depth)
		render.enable_state(render.STATE_BLEND)
		--render.set_depth_mask(true)
		render.enable_state(render.STATE_DEPTH_TEST)
		render.enable_state(render.STATE_CULL_FACE)
		render.draw(self.predicates.skin_shop)

		--render.enable_state(render.STATE_BLEND)
		render.disable_state(render.STATE_CULL_FACE)
		render.disable_state(render.STATE_DEPTH_TEST)

		render.set_view(self.empty_view)
		render.set_projection(self.gui_proj)
		render.disable_state(render.STATE_DEPTH_TEST)
		render.enable_state(render.STATE_STENCIL_TEST)
		render.draw(self.predicates.gui_shop_skin_text)
		render.disable_state(render.STATE_STENCIL_TEST)
	end
end

function Render:on_message(message_id, message)

end

return Render