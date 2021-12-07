#
# Chemical model class.
#
class Colin::Models::Chemical < ActiveRecord::Base
  # Validate the presence of the non-NULLable fields.
  validates_presence_of :cas, :name, :created_at, :updated_at
  validates_inclusion_of :haz_substance, in: [true, false]

  # Validate that sds_url is actually a standard URL.
  # validates :sds_url,
  #           format: { with: URI::DEFAULT_PARSER.make_regexp },
  #           if: proc { |a| a.url.present? }

  # Foreign key relationships
  belongs_to :dg_class, class_name: 'DgClass'
  belongs_to :dg_class_2, class_name: 'DgClass'
  belongs_to :dg_class_3, class_name: 'DgClass'
  belongs_to :schedule
  belongs_to :packing_group
  belongs_to :signal_word

  has_many :chemical_haz_class, class_name: "ChemicalHazClass"
  has_many :chemical_pictogram, class_name: "ChemicalPictogram"
  has_many :chemical_haz_stat, class_name: "ChemicalHazStat"
  has_many :chemical_prec_stat, class_name: "ChemicalPrecStat"

  has_many :haz_class, through: :chemical_haz_class, class_name: "HazClass"
  has_many :pictogram, through: :chemical_pictogram, class_name: "Pictogram"
  has_many :haz_stat, through: :chemical_haz_stat, class_name: "HazStat"
  has_many :prec_stat, through: :chemical_prec_stat, class_name: "PrecStat"

  has_many :containers, class_name: "Container"

  def self.create_chemical(params)
    if params[:cas].blank?
      throw(:halt, [422, 'Must provide a CAS for the chemical.'])
    elsif Colin::Models::Chemical.exists?(cas: params[:cas])
      chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
    else
      #If not, get the safety information supplied and use it to create a new chemical

      if params[:name].blank?
        throw(:halt, [422, 'Must provide a name for the chemical.'])
      end

      if params[:haz_substance].blank? || params[:haz_substance] == 'false'
        haz_substance = false
      elsif params[:haz_substance] == 'true'
        haz_substance = true
      else
        throw(:halt, [422, 'Invalid hazardous substance value.'])
      end

      if params[:dg_class].blank?
        #Nothing to do here!
      elsif Colin::Models::DgClass.exists?(number: params[:dg_class])
        dg_class = Colin::Models::DgClass.where(number: params[:dg_class]).take
      else
        throw(:halt, [422, 'Invalid dangerous goods class.'])
      end

      if params[:dg_class_2].blank?
        #Nothing to do here!
      elsif Colin::Models::DgClass.exists?(number: params[:dg_class_2])
        dg_class_2 = Colin::Models::DgClass.where(number: params[:dg_class_2]).take
      else
        throw(:halt, [422, 'Invalid dangerous goods subclass.'])
      end

      if params[:dg_class_3].blank?
        #Nothing to do here!
      elsif Colin::Models::DgClass.exists?(number: params[:dg_class_3])
        dg_class_3 = Colin::Models::DgClass.where(number: params[:dg_class_3]).take
      else
        throw(:halt, [422, 'Invalid dangerous goods subsubclass.'])
      end

      if params[:schedule].blank?
        #Nothing to do here!
      elsif Colin::Models::Schedule.exists?(number: params[:schedule])
        schedule = Colin::Models::Schedule.where(number: params[:schedule]).take
      else
        throw(:halt, [422, 'Invalid schedule.'])
      end

      if params[:packing_group].blank?
        #Nothing to do here!
      elsif Colin::Models::PackingGroup.exists?(name: params[:packing_group])
        packing_group = Colin::Models::PackingGroup.where(name: params[:packing_group]).take
      else
        throw(:halt, [422, 'Invalid packing group.'])
      end

      if params[:signal_word].blank?
        #Nothing to do here!
      elsif Colin::Models::SignalWord.exists?(name: params[:signal_word])
        signal_word = Colin::Models::SignalWord.where(name: params[:signal_word]).take
      else
        throw(:halt, [422, 'Invalid signal word.'])
      end

      if params[:storage_temperature].blank?
        #Nothing to do here!
      elsif params[:storage_temperature].split('~').length == 1
        storage_temperature_min = params[:storage_temperature]
        storage_temperature_max = params[:storage_temperature]
      else
        storage_temperature_min = params[:storage_temperature].split('~').min
        storage_temperature_max = params[:storage_temperature].split('~').max
      end

      chemical = Colin::Models::Chemical.create(
        cas: params[:cas], 
        prefix: params[:prefix], 
        name: params[:name], 
        haz_substance: haz_substance, 
        un_number: params[:un_number], 
        un_proper_shipping_name: params[:un_proper_shipping_name],
        dg_class: dg_class, 
        dg_class_2: dg_class_2, 
        dg_class_3: dg_class_3, 
        schedule: schedule, 
        packing_group: packing_group,
        storage_temperature_min: storage_temperature_min, 
        storage_temperature_max: storage_temperature_max, 
        inchi: params[:inchi],
        smiles: params[:smiles],
        pubchem: params[:pubchem],
        density: params[:density],
        melting_point: params[:melting_point],
        boiling_point: params[:boiling_point],
        sds: params[:sds],
        created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601
      )

      #Now that we have an instance of the chemical, we can deal with foreign keys

      if params[:haz_stat].blank?
        #Nothing to do here!
      else
        for i in params[:haz_stat].split(';')
          if Colin::Models::HazStat.exists?(code: i)
            haz_stat = Colin::Models::HazStat.where(code: i).take
            Colin::Models::ChemicalHazStat.create!(chemical_id: chemical.id, haz_stat_id: haz_stat.id)
          else
            throw(:halt, [422, "Invalid H statement code #{i} (supply as colon separated list)."])
          end
        end
      end

      if params[:prec_stat].blank?
        #Nothing to do here!
      else
        for i in params[:prec_stat].split(';')
          if Colin::Models::PrecStat.exists?(code: i.split(',')[0])
            prec_stat = Colin::Models::PrecStat.where(code: i.split(',')[0]).take
            chemical_prec_stat = Colin::Models::ChemicalPrecStat.create!(chemical_id: chemical.id, prec_stat_id: prec_stat.id)
            n = 1
            for j in i.split(',').drop(1)
              Colin::Models::ChemicalPrecStatSupp.create!(chemical_prec_stat_id: chemical_prec_stat.id, position: n, information: j)
              n=n+1
            end
          else
            throw(:halt, [422, "Invalid P statement code #{i.split(',')[0]} (supply as colon separated list)."])
          end
        end
      end

      if params[:haz_class].blank?
        #Nothing to do here!
      else
        for i in params[:haz_class].split(';')
          if Colin::Models::HazClass.exists?(description: i.split(',')[0])
            haz_class = Colin::Models::HazClass.where(description: i.split(',')[0]).take
            category = i.split(',')[1]
            chemical_haz_class = Colin::Models::ChemicalHazClass.create!(chemical_id: chemical.id, haz_class_id: haz_class.id, category: category)
          else
            throw(:halt, [422, "Invalid hazard classification #{i.split(',')[0]} (supply as colon separated list)."])
          end
        end
      end

      if params[:pictogram].blank?
        #Nothing to do here!
      else
        for i in params[:pictogram].split(';')
          if Colin::Models::Pictogram.exists?(name: i)
            pictogram = Colin::Models::Pictogram.where(code: i).take
            Colin::Models::ChemicalPictogram.create!(chemical_id: chemical.id, pictogram_id: pictogram.id)
          else
            throw(:halt, [422, "Invalid pictogram name #{i} (supply as colon separated list)."])
          end
        end
      end
      #The chemical has now been created!
    end
    return chemical
  end
end
