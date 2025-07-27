for _, child in ipairs({ UIWidgetPowerBarContainerFrame:GetChildren() }) do
  if child.DecorLeft and child.DecorLeft.GetAtlas then
    local atlasName = child.DecorLeft:GetAtlas()
    if atlasName == "dragonriding_vigor_decor" then
      applySettings(child.DecorLeft, desaturationValue, druidComboPointActive, true, true)
      applySettings(child.DecorRight, desaturationValue, druidComboPointActive, true, true)
    end
  end
  for _, grandchild in ipairs({ child:GetChildren() }) do
    -- Check for textures with specific atlas names
    if grandchild.Frame and grandchild.Frame.GetAtlas then
      local atlasName = grandchild.Frame:GetAtlas()
      if atlasName == "dragonriding_vigor_frame" then
        applySettings(grandchild.Frame, desaturationValue, druidComboPointActive, true, true)
      end
    end
  end
end
