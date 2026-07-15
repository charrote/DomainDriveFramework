-- ============================================================
-- DDF 数据库迁移脚本
-- 生成时间: 2026-07-14T17:40:30.327Z
-- 引擎版本: 1.0.0
-- ============================================================

-- 启用 UUID 扩展（如需要）
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 实体表定义（共 33 个）
-- ============================================================


-- --------------------------------------------------------
-- 1. Barcode — 条码
-- Domain: base.barcode
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `barcode` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `barcode` VARCHAR(255) NOT NULL,
  `material_code` VARCHAR(255) NOT NULL,
  `batch_no` VARCHAR(255) NOT NULL,
  `quantity` DECIMAL(12,4) DEFAULT 0,
  `status` VARCHAR(50) NOT NULL,
  `production_date` DATE NOT NULL,
  `work_order_no` INT NOT NULL,
  `container_id` INT NOT NULL,
  `remark` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_barcode_status` ON `barcode` (`status`);
CREATE INDEX `idx_barcode_work_order_no` ON `barcode` (`work_order_no`);
CREATE INDEX `idx_barcode_container_id` ON `barcode` (`container_id`);
ALTER TABLE `barcode` ADD CONSTRAINT `fk_barcode_work_order_no`
  FOREIGN KEY (`work_order_no`) REFERENCES `work_order`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `barcode` ADD CONSTRAINT `fk_barcode_container_id`
  FOREIGN KEY (`container_id`) REFERENCES `container`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 2. ProductBOM — 产品 BOM
-- Domain: base.bom
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `product_bom` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bom_code` VARCHAR(255) NOT NULL,
  `product_code` VARCHAR(255) NOT NULL,
  `product_name` VARCHAR(255) NOT NULL,
  `version` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE UNIQUE INDEX `idx_product_bom_product_code` ON `product_bom` (`product_code`);
CREATE INDEX `idx_product_bom_status` ON `product_bom` (`status`);


-- --------------------------------------------------------
-- 3. BOMItem — BOM 明细
-- Domain: base.bom
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bom_item` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_bom_id` INT NOT NULL,
  `material_code` VARCHAR(255) NOT NULL,
  `material_name` VARCHAR(255) NOT NULL,
  `quantity` DECIMAL(12,4) DEFAULT 0,
  `unit` VARCHAR(255) NOT NULL,
  `scrap_rate` DECIMAL(12,4) DEFAULT 0,
  `parent_item_id` INT NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_bom_item_product_bom_id` ON `bom_item` (`product_bom_id`);
CREATE INDEX `idx_bom_item_parent_item_id` ON `bom_item` (`parent_item_id`);
ALTER TABLE `bom_item` ADD CONSTRAINT `fk_bom_item_product_bom_id`
  FOREIGN KEY (`product_bom_id`) REFERENCES `product_bom`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `bom_item` ADD CONSTRAINT `fk_bom_item_parent_item_id`
  FOREIGN KEY (`parent_item_id`) REFERENCES `bom_item`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 4. CodingRule — 编码规则
-- Domain: base.coding_rule
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `coding_rule` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rule_code` VARCHAR(255) NOT NULL,
  `rule_name` VARCHAR(255) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `prefix` VARCHAR(255) NOT NULL,
  `date_format` VARCHAR(255) NOT NULL,
  `seq_digits` INT DEFAULT 0,
  `seq_strategy` VARCHAR(50) NOT NULL,
  `seq_scope` VARCHAR(50) NOT NULL,
  `sample_output` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_coding_rule_entity_type` ON `coding_rule` (`entity_type`);
CREATE INDEX `idx_coding_rule_seq_strategy` ON `coding_rule` (`seq_strategy`);
CREATE INDEX `idx_coding_rule_seq_scope` ON `coding_rule` (`seq_scope`);
CREATE INDEX `idx_coding_rule_status` ON `coding_rule` (`status`);


-- --------------------------------------------------------
-- 5. Container — 容器
-- Domain: base.container
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `container` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `container_code` VARCHAR(255) NOT NULL,
  `container_name` VARCHAR(255) NOT NULL,
  `container_type` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `max_weight_kg` DECIMAL(12,4) DEFAULT 0,
  `device_id` INT NOT NULL,
  `workstation_id` INT NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_container_container_type` ON `container` (`container_type`);
CREATE INDEX `idx_container_status` ON `container` (`status`);
CREATE INDEX `idx_container_device_id` ON `container` (`device_id`);
CREATE INDEX `idx_container_workstation_id` ON `container` (`workstation_id`);
ALTER TABLE `container` ADD CONSTRAINT `fk_container_device_id`
  FOREIGN KEY (`device_id`) REFERENCES `device`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `container` ADD CONSTRAINT `fk_container_workstation_id`
  FOREIGN KEY (`workstation_id`) REFERENCES `workstation`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 6. DefectCategory — 缺陷分类
-- Domain: base.defect
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `defect_category` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_code` VARCHAR(255) NOT NULL,
  `category_name` VARCHAR(255) NOT NULL,
  `parent_id` INT NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_defect_category_parent_id` ON `defect_category` (`parent_id`);
ALTER TABLE `defect_category` ADD CONSTRAINT `fk_defect_category_parent_id`
  FOREIGN KEY (`parent_id`) REFERENCES `defect_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 7. Defect — 缺陷
-- Domain: base.defect
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `defect` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `defect_code` VARCHAR(255) NOT NULL,
  `defect_name` VARCHAR(255) NOT NULL,
  `category_id` INT NOT NULL,
  `severity` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_defect_category_id` ON `defect` (`category_id`);
CREATE INDEX `idx_defect_severity` ON `defect` (`severity`);
CREATE INDEX `idx_defect_status` ON `defect` (`status`);
ALTER TABLE `defect` ADD CONSTRAINT `fk_defect_category_id`
  FOREIGN KEY (`category_id`) REFERENCES `defect_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 8. DeviceCategory — 设备分类
-- Domain: base.device
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `device_category` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_code` VARCHAR(255) NOT NULL,
  `category_name` VARCHAR(255) NOT NULL,
  `parent_id` INT NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_device_category_parent_id` ON `device_category` (`parent_id`);
ALTER TABLE `device_category` ADD CONSTRAINT `fk_device_category_parent_id`
  FOREIGN KEY (`parent_id`) REFERENCES `device_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 9. Device — 设备
-- Domain: base.device
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `device` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_code` VARCHAR(255) NOT NULL,
  `device_name` VARCHAR(255) NOT NULL,
  `device_type` VARCHAR(50) NOT NULL,
  `category_id` INT NOT NULL,
  `model` VARCHAR(255) NOT NULL,
  `production_line_id` INT NOT NULL,
  `workstation_id` INT NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `purchase_date` DATE NOT NULL,
  `last_maintenance_date` DATE NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_device_device_type` ON `device` (`device_type`);
CREATE INDEX `idx_device_category_id` ON `device` (`category_id`);
CREATE INDEX `idx_device_production_line_id` ON `device` (`production_line_id`);
CREATE INDEX `idx_device_workstation_id` ON `device` (`workstation_id`);
CREATE INDEX `idx_device_status` ON `device` (`status`);
ALTER TABLE `device` ADD CONSTRAINT `fk_device_category_id`
  FOREIGN KEY (`category_id`) REFERENCES `device_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `device` ADD CONSTRAINT `fk_device_production_line_id`
  FOREIGN KEY (`production_line_id`) REFERENCES `org_production_line`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `device` ADD CONSTRAINT `fk_device_workstation_id`
  FOREIGN KEY (`workstation_id`) REFERENCES `workstation`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 10. InspectionItem — 检验项目
-- Domain: base.inspection_item
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `inspection_item` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_code` VARCHAR(255) NOT NULL,
  `item_name` VARCHAR(255) NOT NULL,
  `quality_category_id` INT NOT NULL,
  `data_type` VARCHAR(50) NOT NULL,
  `unit` VARCHAR(255) NOT NULL,
  `spec_min` DECIMAL(12,4) DEFAULT 0,
  `spec_max` DECIMAL(12,4) DEFAULT 0,
  `options` VARCHAR(255) NOT NULL,
  `method` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_inspection_item_quality_category_id` ON `inspection_item` (`quality_category_id`);
CREATE INDEX `idx_inspection_item_data_type` ON `inspection_item` (`data_type`);
CREATE INDEX `idx_inspection_item_status` ON `inspection_item` (`status`);
ALTER TABLE `inspection_item` ADD CONSTRAINT `fk_inspection_item_quality_category_id`
  FOREIGN KEY (`quality_category_id`) REFERENCES `quality_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 11. InspectionPlan — 抽样方案
-- Domain: base.inspection_plan
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `inspection_plan` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `plan_code` VARCHAR(255) NOT NULL,
  `plan_name` VARCHAR(255) NOT NULL,
  `check_type` VARCHAR(50) NOT NULL,
  `batch_min` INT DEFAULT 0,
  `batch_max` INT DEFAULT 0,
  `sample_size` INT DEFAULT 0,
  `accept_limit` INT DEFAULT 0,
  `reject_limit` INT DEFAULT 0,
  `severity` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_inspection_plan_check_type` ON `inspection_plan` (`check_type`);
CREATE INDEX `idx_inspection_plan_severity` ON `inspection_plan` (`severity`);
CREATE INDEX `idx_inspection_plan_status` ON `inspection_plan` (`status`);


-- --------------------------------------------------------
-- 12. MaterialCategory — 物料分类
-- Domain: base.material
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `material_category` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_code` VARCHAR(255) NOT NULL,
  `category_name` VARCHAR(255) NOT NULL,
  `level` INT DEFAULT 0,
  `parent_id` INT NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_material_category_parent_id` ON `material_category` (`parent_id`);
ALTER TABLE `material_category` ADD CONSTRAINT `fk_material_category_parent_id`
  FOREIGN KEY (`parent_id`) REFERENCES `material_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 13. Material — 物料
-- Domain: base.material
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `material` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `material_code` VARCHAR(255) NOT NULL,
  `material_name` VARCHAR(255) NOT NULL,
  `specification` VARCHAR(255) NOT NULL,
  `category_id` INT NOT NULL,
  `unit` VARCHAR(50) NOT NULL,
  `material_type` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_material_category_id` ON `material` (`category_id`);
CREATE INDEX `idx_material_unit` ON `material` (`unit`);
CREATE INDEX `idx_material_material_type` ON `material` (`material_type`);
CREATE INDEX `idx_material_status` ON `material` (`status`);
ALTER TABLE `material` ADD CONSTRAINT `fk_material_category_id`
  FOREIGN KEY (`category_id`) REFERENCES `material_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 14. MaterialAttrTemplate — 物料属性模板
-- Domain: base.material_attr_template
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `material_attr_template` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `attr_code` VARCHAR(255) NOT NULL,
  `attr_name` VARCHAR(255) NOT NULL,
  `attr_type` VARCHAR(50) NOT NULL,
  `options` VARCHAR(255) NOT NULL,
  `unit` VARCHAR(255) NOT NULL,
  `required` BOOLEAN DEFAULT FALSE,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_material_attr_template_attr_type` ON `material_attr_template` (`attr_type`);
CREATE INDEX `idx_material_attr_template_status` ON `material_attr_template` (`status`);


-- --------------------------------------------------------
-- 15. MaterialAttrValue — 物料属性值
-- Domain: base.material_attr_template
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `material_attr_value` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `material_id` INT NOT NULL,
  `attr_id` INT NOT NULL,
  `value` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_material_attr_value_material_id` ON `material_attr_value` (`material_id`);
CREATE INDEX `idx_material_attr_value_attr_id` ON `material_attr_value` (`attr_id`);
ALTER TABLE `material_attr_value` ADD CONSTRAINT `fk_material_attr_value_material_id`
  FOREIGN KEY (`material_id`) REFERENCES `material`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `material_attr_value` ADD CONSTRAINT `fk_material_attr_value_attr_id`
  FOREIGN KEY (`attr_id`) REFERENCES `material_attr_template`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 16. Operator — 作业人员
-- Domain: base.operator
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `operator` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `operator_no` VARCHAR(255) NOT NULL,
  `operator_name` VARCHAR(255) NOT NULL,
  `user_id` INT NOT NULL,
  `production_line_id` INT NOT NULL,
  `shift_id` INT NOT NULL,
  `skill_level` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `phone` VARCHAR(255) NOT NULL,
  `hire_date` DATE NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_operator_user_id` ON `operator` (`user_id`);
CREATE INDEX `idx_operator_production_line_id` ON `operator` (`production_line_id`);
CREATE INDEX `idx_operator_shift_id` ON `operator` (`shift_id`);
CREATE INDEX `idx_operator_skill_level` ON `operator` (`skill_level`);
CREATE INDEX `idx_operator_status` ON `operator` (`status`);
ALTER TABLE `operator` ADD CONSTRAINT `fk_operator_user_id`
  FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `operator` ADD CONSTRAINT `fk_operator_production_line_id`
  FOREIGN KEY (`production_line_id`) REFERENCES `org_production_line`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `operator` ADD CONSTRAINT `fk_operator_shift_id`
  FOREIGN KEY (`shift_id`) REFERENCES `shift`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 17. Factory — 工厂
-- Domain: base.org_structure
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `org_factory` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `factory_code` VARCHAR(255) NOT NULL,
  `factory_name` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_org_factory_status` ON `org_factory` (`status`);


-- --------------------------------------------------------
-- 18. Workshop — 车间
-- Domain: base.org_structure
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `org_workshop` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `factory_id` INT NOT NULL,
  `workshop_code` VARCHAR(255) NOT NULL,
  `workshop_name` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_org_workshop_factory_id` ON `org_workshop` (`factory_id`);
CREATE INDEX `idx_org_workshop_status` ON `org_workshop` (`status`);
ALTER TABLE `org_workshop` ADD CONSTRAINT `fk_org_workshop_factory_id`
  FOREIGN KEY (`factory_id`) REFERENCES `org_factory`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 19. ProductionLine — 产线
-- Domain: base.org_structure
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `org_production_line` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `workshop_id` INT NOT NULL,
  `line_code` VARCHAR(255) NOT NULL,
  `line_name` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_org_production_line_workshop_id` ON `org_production_line` (`workshop_id`);
CREATE INDEX `idx_org_production_line_status` ON `org_production_line` (`status`);
ALTER TABLE `org_production_line` ADD CONSTRAINT `fk_org_production_line_workshop_id`
  FOREIGN KEY (`workshop_id`) REFERENCES `org_workshop`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 20. ProcessParam — 工艺参数
-- Domain: base.process_param
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `process_param` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `param_code` VARCHAR(255) NOT NULL,
  `param_name` VARCHAR(255) NOT NULL,
  `process_step_id` INT NOT NULL,
  `data_type` VARCHAR(50) NOT NULL,
  `unit` VARCHAR(255) NOT NULL,
  `spec_min` DECIMAL(12,4) DEFAULT 0,
  `spec_max` DECIMAL(12,4) DEFAULT 0,
  `options` VARCHAR(255) NOT NULL,
  `required` BOOLEAN DEFAULT FALSE,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_process_param_process_step_id` ON `process_param` (`process_step_id`);
CREATE INDEX `idx_process_param_data_type` ON `process_param` (`data_type`);
CREATE INDEX `idx_process_param_status` ON `process_param` (`status`);
ALTER TABLE `process_param` ADD CONSTRAINT `fk_process_param_process_step_id`
  FOREIGN KEY (`process_step_id`) REFERENCES `process_step`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 21. ProcessRoute — 工艺路线
-- Domain: base.process_route
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `process_route` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_code` VARCHAR(255) NOT NULL,
  `product_code` VARCHAR(255) NOT NULL,
  `version` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `total_standard_time` INT DEFAULT 0,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE UNIQUE INDEX `idx_process_route_product_code` ON `process_route` (`product_code`);
CREATE INDEX `idx_process_route_status` ON `process_route` (`status`);


-- --------------------------------------------------------
-- 22. ProcessStep — 工序
-- Domain: base.process_step
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `process_step` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `process_route_id` INT NOT NULL,
  `step_no` INT DEFAULT 0,
  `step_code` VARCHAR(255) NOT NULL,
  `step_name` VARCHAR(255) NOT NULL,
  `standard_time_minutes` INT DEFAULT 0,
  `device_type_required` VARCHAR(50) NOT NULL,
  `workstation_type` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_process_step_process_route_id` ON `process_step` (`process_route_id`);
CREATE INDEX `idx_process_step_device_type_required` ON `process_step` (`device_type_required`);
ALTER TABLE `process_step` ADD CONSTRAINT `fk_process_step_process_route_id`
  FOREIGN KEY (`process_route_id`) REFERENCES `process_route`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 23. ProductionRecord — 生产记录
-- Domain: base.production_record
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `production_record` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `record_no` VARCHAR(255) NOT NULL,
  `work_order_no` INT NOT NULL,
  `process_step_id` INT NOT NULL,
  `operator_id` INT NOT NULL,
  `device_id` INT NOT NULL,
  `shift_id` INT NOT NULL,
  `production_line_id` INT NOT NULL,
  `start_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `end_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `output_quantity` INT DEFAULT 0,
  `scrap_quantity` INT DEFAULT 0,
  `status` VARCHAR(50) NOT NULL,
  `remark` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_production_record_work_order_no` ON `production_record` (`work_order_no`);
CREATE INDEX `idx_production_record_process_step_id` ON `production_record` (`process_step_id`);
CREATE INDEX `idx_production_record_operator_id` ON `production_record` (`operator_id`);
CREATE INDEX `idx_production_record_device_id` ON `production_record` (`device_id`);
CREATE INDEX `idx_production_record_shift_id` ON `production_record` (`shift_id`);
CREATE INDEX `idx_production_record_production_line_id` ON `production_record` (`production_line_id`);
CREATE INDEX `idx_production_record_status` ON `production_record` (`status`);
ALTER TABLE `production_record` ADD CONSTRAINT `fk_production_record_work_order_no`
  FOREIGN KEY (`work_order_no`) REFERENCES `work_order`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `production_record` ADD CONSTRAINT `fk_production_record_process_step_id`
  FOREIGN KEY (`process_step_id`) REFERENCES `process_step`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `production_record` ADD CONSTRAINT `fk_production_record_operator_id`
  FOREIGN KEY (`operator_id`) REFERENCES `operator`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `production_record` ADD CONSTRAINT `fk_production_record_device_id`
  FOREIGN KEY (`device_id`) REFERENCES `device`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `production_record` ADD CONSTRAINT `fk_production_record_shift_id`
  FOREIGN KEY (`shift_id`) REFERENCES `shift`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `production_record` ADD CONSTRAINT `fk_production_record_production_line_id`
  FOREIGN KEY (`production_line_id`) REFERENCES `org_production_line`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 24. QualityCategory — 质量分类
-- Domain: base.quality_category
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quality_category` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_code` VARCHAR(255) NOT NULL,
  `category_name` VARCHAR(255) NOT NULL,
  `level` INT DEFAULT 0,
  `parent_id` INT NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_quality_category_parent_id` ON `quality_category` (`parent_id`);
CREATE INDEX `idx_quality_category_status` ON `quality_category` (`status`);
ALTER TABLE `quality_category` ADD CONSTRAINT `fk_quality_category_parent_id`
  FOREIGN KEY (`parent_id`) REFERENCES `quality_category`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 25. QualityCheck — 质检记录
-- Domain: base.quality_check
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quality_check` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `check_no` VARCHAR(255) NOT NULL,
  `work_order_no` INT NOT NULL,
  `production_record_id` INT NOT NULL,
  `check_type` VARCHAR(50) NOT NULL,
  `check_name` VARCHAR(255) NOT NULL,
  `inspection_item_id` INT NOT NULL,
  `sample_size` INT DEFAULT 0,
  `measured_value` DECIMAL(12,4) DEFAULT 0,
  `tolerance_min` DECIMAL(12,4) DEFAULT 0,
  `tolerance_max` DECIMAL(12,4) DEFAULT 0,
  `result` VARCHAR(50) NOT NULL,
  `defect_id` INT NOT NULL,
  `inspector_id` INT NOT NULL,
  `check_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `remark` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_quality_check_work_order_no` ON `quality_check` (`work_order_no`);
CREATE INDEX `idx_quality_check_production_record_id` ON `quality_check` (`production_record_id`);
CREATE INDEX `idx_quality_check_check_type` ON `quality_check` (`check_type`);
CREATE INDEX `idx_quality_check_inspection_item_id` ON `quality_check` (`inspection_item_id`);
CREATE INDEX `idx_quality_check_result` ON `quality_check` (`result`);
CREATE INDEX `idx_quality_check_defect_id` ON `quality_check` (`defect_id`);
CREATE INDEX `idx_quality_check_inspector_id` ON `quality_check` (`inspector_id`);
ALTER TABLE `quality_check` ADD CONSTRAINT `fk_quality_check_work_order_no`
  FOREIGN KEY (`work_order_no`) REFERENCES `work_order`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `quality_check` ADD CONSTRAINT `fk_quality_check_production_record_id`
  FOREIGN KEY (`production_record_id`) REFERENCES `production_record`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `quality_check` ADD CONSTRAINT `fk_quality_check_inspection_item_id`
  FOREIGN KEY (`inspection_item_id`) REFERENCES `inspection_item`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `quality_check` ADD CONSTRAINT `fk_quality_check_defect_id`
  FOREIGN KEY (`defect_id`) REFERENCES `defect`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `quality_check` ADD CONSTRAINT `fk_quality_check_inspector_id`
  FOREIGN KEY (`inspector_id`) REFERENCES `sys_user`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 26. ShiftPattern — 班制
-- Domain: base.shift
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `shift_pattern` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pattern_name` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------
-- 27. Shift — 班次
-- Domain: base.shift
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `shift` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shift_code` VARCHAR(255) NOT NULL,
  `shift_name` VARCHAR(255) NOT NULL,
  `start_time` VARCHAR(255) NOT NULL,
  `end_time` VARCHAR(255) NOT NULL,
  `shift_date` DATE NOT NULL,
  `shift_pattern_id` INT NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_shift_shift_pattern_id` ON `shift` (`shift_pattern_id`);
ALTER TABLE `shift` ADD CONSTRAINT `fk_shift_shift_pattern_id`
  FOREIGN KEY (`shift_pattern_id`) REFERENCES `shift_pattern`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 28. Skill — 技能
-- Domain: base.skill
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `skill` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `skill_code` VARCHAR(255) NOT NULL,
  `skill_name` VARCHAR(255) NOT NULL,
  `category` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_skill_status` ON `skill` (`status`);


-- --------------------------------------------------------
-- 29. OperatorSkill — 人员技能
-- Domain: base.skill
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `operator_skill` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `operator_id` INT NOT NULL,
  `skill_id` INT NOT NULL,
  `skill_level` VARCHAR(50) NOT NULL,
  `certified` BOOLEAN DEFAULT FALSE,
  `expire_date` DATE NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_operator_skill_operator_id` ON `operator_skill` (`operator_id`);
CREATE INDEX `idx_operator_skill_skill_id` ON `operator_skill` (`skill_id`);
CREATE INDEX `idx_operator_skill_skill_level` ON `operator_skill` (`skill_level`);
ALTER TABLE `operator_skill` ADD CONSTRAINT `fk_operator_skill_operator_id`
  FOREIGN KEY (`operator_id`) REFERENCES `operator`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `operator_skill` ADD CONSTRAINT `fk_operator_skill_skill_id`
  FOREIGN KEY (`skill_id`) REFERENCES `skill`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 30. User — 用户
-- Domain: base.user
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sys_user` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(255) NOT NULL,
  `real_name` VARCHAR(255) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_sys_user_role` ON `sys_user` (`role`);
CREATE INDEX `idx_sys_user_status` ON `sys_user` (`status`);


-- --------------------------------------------------------
-- 31. WorkOrder — 工单
-- Domain: base.work_order
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `work_order` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_no` VARCHAR(255) NOT NULL,
  `product_code` VARCHAR(255) NOT NULL,
  `product_name` VARCHAR(255) NOT NULL,
  `quantity` INT DEFAULT 0,
  `completed_quantity` INT DEFAULT 0,
  `scrap_quantity` INT DEFAULT 0,
  `status` VARCHAR(50) NOT NULL,
  `priority` VARCHAR(50) NOT NULL,
  `plan_start_date` DATE NOT NULL,
  `plan_end_date` DATE NOT NULL,
  `actual_start_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `actual_end_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `route_id` INT NOT NULL,
  `production_line_id` INT NOT NULL,
  `shift_id` INT NOT NULL,
  `comment` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE UNIQUE INDEX `idx_work_order_order_no` ON `work_order` (`order_no`);
CREATE UNIQUE INDEX `idx_work_order_product_code` ON `work_order` (`product_code`);
CREATE INDEX `idx_work_order_status` ON `work_order` (`status`);
CREATE INDEX `idx_work_order_priority` ON `work_order` (`priority`);
CREATE INDEX `idx_work_order_route_id` ON `work_order` (`route_id`);
CREATE INDEX `idx_work_order_production_line_id` ON `work_order` (`production_line_id`);
CREATE INDEX `idx_work_order_shift_id` ON `work_order` (`shift_id`);
CREATE INDEX `idx_work_order_created_by` ON `work_order` (`created_by`);
ALTER TABLE `work_order` ADD CONSTRAINT `fk_work_order_route_id`
  FOREIGN KEY (`route_id`) REFERENCES `process_route`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `work_order` ADD CONSTRAINT `fk_work_order_production_line_id`
  FOREIGN KEY (`production_line_id`) REFERENCES `org_production_line`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `work_order` ADD CONSTRAINT `fk_work_order_shift_id`
  FOREIGN KEY (`shift_id`) REFERENCES `shift`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE `work_order` ADD CONSTRAINT `fk_work_order_created_by`
  FOREIGN KEY (`created_by`) REFERENCES `sys_user`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 32. WOBOMItem — 工单 BOM 明细
-- Domain: base.work_order_bom
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `wo_bom_item` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `work_order_no` INT NOT NULL,
  `material_code` VARCHAR(255) NOT NULL,
  `material_name` VARCHAR(255) NOT NULL,
  `required_qty` DECIMAL(12,4) DEFAULT 0,
  `consumed_qty` DECIMAL(12,4) DEFAULT 0,
  `unit` VARCHAR(255) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_wo_bom_item_work_order_no` ON `wo_bom_item` (`work_order_no`);
ALTER TABLE `wo_bom_item` ADD CONSTRAINT `fk_wo_bom_item_work_order_no`
  FOREIGN KEY (`work_order_no`) REFERENCES `work_order`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- --------------------------------------------------------
-- 33. Workstation — 工位
-- Domain: base.workstation
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `workstation` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `station_code` VARCHAR(255) NOT NULL,
  `station_name` VARCHAR(255) NOT NULL,
  `production_line_id` INT NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `created_by` INT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX `idx_workstation_production_line_id` ON `workstation` (`production_line_id`);
CREATE INDEX `idx_workstation_status` ON `workstation` (`status`);
ALTER TABLE `workstation` ADD CONSTRAINT `fk_workstation_production_line_id`
  FOREIGN KEY (`production_line_id`) REFERENCES `org_production_line`(`id`)
  ON DELETE SET NULL ON UPDATE CASCADE;


-- ============================================================
-- 初始化管理员用户
-- ============================================================
-- INSERT INTO `user` (`username`, `password_hash`, `role`) VALUES ('admin', '<hash>', 'admin');
