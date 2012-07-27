require 'test_helper'

describe Model do

  it "should enforce validations" do
    brand1     = FactoryGirl.build(:brand)
    model1     = FactoryGirl.build(:model, name: nil, brand: brand1)
    model2     = FactoryGirl.build(:model)

    # missing name
    model1.wont_be :valid?

    # missing brand
    model2.wont_be :valid?
  end

  it "should work" do
    brand1     = FactoryGirl.create(:brand)
    model1     = FactoryGirl.create(:model, brand: brand1)

    component1 = FactoryGirl.build(:component, model: model1, asset_tag: "AAA")
    location1  = FactoryGirl.build(:location)
    kit1       = FactoryGirl.create(:checkoutable_kit, components: [component1], location: location1)

    component2 = FactoryGirl.build(:component, model: model1, asset_tag: "BBB")
    component5 = FactoryGirl.build(:component, model: model1, asset_tag: "EEE")
    location2  = FactoryGirl.build(:location, name: "Beale Street")
    kit2       = FactoryGirl.create(:kit, components: [component2, component5], location: location2)

    brand2     = FactoryGirl.create(:brand, name: "Glaxo Smith Kline")
    model2     = FactoryGirl.create(:model, brand: brand2)

    component3 = FactoryGirl.build(:component, model: model2, asset_tag: "CCC")
    kit3       = FactoryGirl.create(:kit, components: [component3], location: location1)

    component4 = FactoryGirl.build(:component, model: model2, asset_tag: "DDD")
    kit4       = FactoryGirl.create(:kit, components: [component4], location: location2)

    model3     = FactoryGirl.create(:model, training_required: true, brand: brand2)

    model1.must_be :valid?
    model2.must_be :valid?
    model3.must_be :valid?

    # since we have 1 checkoutable kit for model1, Model.checkoutable should return 1
    checkoutable_models = Model.checkoutable
    checkoutable_models.length.must_equal 1
    checkoutable_models.must_include model1

    # scoped by brand
    brand1_models = Model.brand(brand1.id)
    brand1_models.must_include model1
    brand1_models.length.must_equal 1

    brand2_models = Model.brand(brand2.id)
    brand2_models.must_include model2
    brand2_models.must_include model3
    brand2_models.length.must_equal 2
    
    # check instances
    model1.must_be :checkoutable?
    model1.checkoutable_kits.must_include kit1
    model1.checkoutable_kits.length.must_equal 1
    model1.checkoutable_kits.wont_include kit2
    model1.wont_be :training_required?
    model1.kit_asset_tags.length.must_equal 3
    model1.kit_asset_tags.must_include ["AAA", kit1]
    model1.kit_asset_tags.must_include ["BBB", kit2]
    model1.kit_asset_tags.must_include ["EEE", kit2]
    model1.kit_asset_tags.wont_include ["CCC", kit3]
    model1.kit_asset_tags.wont_include ["DDD", kit4]

    model2.wont_be :checkoutable?
    model2.checkoutable_kits.length.must_equal 0
    model2.wont_be :training_required?
    
    model3.wont_be :checkoutable?
    model3.checkoutable_kits.length.must_equal 0
    model3.must_be :training_required?

  end

end
