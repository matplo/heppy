#include "GroomerShopUI.hh"
#include "GroomerShop.hh"

#include <limits>
#include <vector>
#include <algorithm>
#include <cmath>
#include <sstream>
#include <fastjet/LimitedWarning.hh>

FASTJET_BEGIN_NAMESPACE      // defined in fastjet/internal/base.hh

namespace contrib 
{
	namespace GroomerShopUtilUI
	{
	    static LundDeclustering _zero_split = LundDeclustering();
	    static LundDeclustering *zero_split() 
	    {
	    	_zero_split.reset();
	    	return &_zero_split;
	    }
    	static LimitedWarning _warnings = LimitedWarning();
    };

	void setGroomer(PseudoJet& jet, JetAlgorithm jet_alg)
	{
		if (jet.has_user_info<GroomerShopUI>())
		{
			GroomerShopUtilUI::_warnings.warn("GroomerShopUtilUI already present within the jet");
		}
		jet.set_user_info(new GroomerShopUI(jet, jet_alg));
	}

	void setGroomer(PseudoJet& jet, const double& R0, JetAlgorithm jet_alg)
	{
		if (jet.has_user_info<GroomerShopUI>())
		{
			GroomerShopUtilUI::_warnings.warn("GroomerShopUtilUI already present within the jet");
		}
		jet.set_user_info(new GroomerShopUI(jet, R0, jet_alg));
	}

	const GroomerShopUI *groom(PseudoJet& jet, 
								const double& R0,
								JetAlgorithm jet_alg,
								const bool& reset)
	{
		if (reset)
		{
			setGroomer(jet, R0, jet_alg);
		}
		if (jet.has_user_info<GroomerShopUI>())
		{
			return &jet.user_info<GroomerShopUI>();
		}
		else
		{
			setGroomer(jet, R0, jet_alg);
			if (jet.has_user_info<GroomerShopUI>())
			{
				return &jet.user_info<GroomerShopUI>();
			}
		}
		return (GroomerShopUI *)0x0;
	}

    GroomerShopUI::~GroomerShopUI()
    {
    	// debug to check if destructor called properly
		// GroomerShopUtilUI::_warnings.warn("delete");    	
    }

	/// recluster and set the vector of primary lund plane splittings
	bool GroomerShopUI::recluster(const PseudoJet& jet)
	{
		_lund_splits.clear();
		_lund_splits = _lund_gen.result(jet);
		return (_lund_splits.size() > 0);
	}


	/// obtain the declusterings of the primary plane of the jet
	std::vector<LundDeclustering> GroomerShopUI::lund_splits() const
	{
		return _lund_splits;
	}

 	/// set the declusterings of the primary plane of the jet
	void GroomerShopUI::set_lund_splits(const std::vector<LundDeclustering>& lunds)
	{
		_lund_splits = lunds;
	}

	/// description of the class
	std::string GroomerShopUI::description() const 
	{
		std::ostringstream oss;
		oss << "GroomerShop with " << _lund_gen.description();
		return oss.str();
	}

	// return the split of dynamical grooming with alpha
	// https://arxiv.org/abs/1911.00375
	LundDeclustering* GroomerShopUI::dynamical(const double& alpha)
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double min_kappa = std::numeric_limits<double>::max();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			// double kappa = 1/(z * (1-z) * pt * pow(theta,a_));
			double kappa = 1. / ( _lund_splits[i].z() * (1. - _lund_splits[i].z()) * _lund_splits[i].pair().pt() * pow(_lund_splits[i].Delta(), alpha));
			if (min_kappa > kappa)
			{
				min_kappa = kappa;
				result = &_lund_splits[i];
			}
		}
		if (min_kappa == std::numeric_limits<double>::max())
		{
			// throw Error("minimum kappa not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("minimum kappa not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max pT split grooming ----
	/// obtain the splitting of max{pT's of softer prongs}
	LundDeclustering* GroomerShopUI::max_pt_softer()
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double max_pt_softer = std::numeric_limits<double>::min();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			if (_lund_splits[i].softer().pt() > max_pt_softer)
			{
				max_pt_softer = _lund_splits[i].softer().pt();
				result = &_lund_splits[i];
			}
		}
		if (max_pt_softer == std::numeric_limits<double>::min())
		{
			// throw Error("max pt softer not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("max pt softer not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max z split grooming ----
	/// obtain the splitting of max{z_i}
	LundDeclustering* GroomerShopUI::max_z()
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double max_z = std::numeric_limits<double>::min();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			if (_lund_splits[i].z() > max_z)
			{
				max_z = _lund_splits[i].z();
				result = &_lund_splits[i];
			}
		}
		if (max_z == std::numeric_limits<double>::min())
		{
			// throw Error("max z not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("max z not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max kt split grooming ----
	/// obtain the splitting of max{kt_i}
	LundDeclustering* GroomerShopUI::max_kt()
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double max_kt = std::numeric_limits<double>::min();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			if (_lund_splits[i].kt() > max_kt)
			{
				max_kt = _lund_splits[i].kt();
				result = &_lund_splits[i];
			}
		}
		if (max_kt == std::numeric_limits<double>::min())
		{
			// throw Error("max kt not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("max kt not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max kappa split grooming ----
	/// obtain the splitting of max{kappa_i}
	LundDeclustering* GroomerShopUI::max_kappa()
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double max_kappa = std::numeric_limits<double>::min();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			if (_lund_splits[i].kappa() > max_kappa)
			{
				max_kappa = _lund_splits[i].kappa();
				result = &_lund_splits[i];
			}
		}
		if (max_kappa == std::numeric_limits<double>::min())
		{
			// throw Error("max kappa not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("max kappa not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max tf split grooming ----
	/// obtain the splitting of min{tf_i}
	/// note t_f = 1/(z\Delta^2) - so we maximize z\Delta^2
	LundDeclustering* GroomerShopUI::min_tf()
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double max_tf = std::numeric_limits<double>::min();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			double _tf = _lund_splits[i].z() * _lund_splits[i].Delta() * _lund_splits[i].Delta();
			if (_tf > max_tf)
			{
				max_tf = _tf;
				result = &_lund_splits[i];
			}
		}
		if (max_tf == std::numeric_limits<double>::min())
		{
			// throw Error("max tf not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("max tf not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// min tf split grooming ----
	/// obtain the splitting of max{tf_i}
	/// note t_f = 1/(z\Delta^2) - so we minimize z\Delta^2
	LundDeclustering* GroomerShopUI::max_tf()
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		double min_tf = std::numeric_limits<double>::max();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			double _tf = _lund_splits[i].z() * _lund_splits[i].Delta() * _lund_splits[i].Delta();
			if (_tf < min_tf)
			{
				min_tf = _tf;
				result = &_lund_splits[i];
			}
		}
		if (min_tf == std::numeric_limits<double>::max())
		{
			// throw Error("min tf not found for a given jet");
			GroomerShopUtilUI::_warnings.warn("min tf not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	// soft drop
	LundDeclustering* GroomerShopUI::soft_drop(double beta, double zcut, double R0)
	{
		LundDeclustering* result = GroomerShopUtilUI::zero_split();
		for (unsigned int i = 0; i < _lund_splits.size(); i++)
		{
			if (_lund_splits[i].z() > zcut * pow(_lund_splits[i].Delta() / R0, beta))
			{
				result = &_lund_splits[i];
				break;
			}
		}
		// no warning about no SD splits - consider returning the jet + last clustering step (but this would have the wrong z)
		// if (result == GroomerShopUtilUI::zero_split())
		// {
		// 	std::stringstream os;
		// 	os << "softdrop returning 'empty' split " << result->z();
		// 	GroomerShopUtilUI::_warnings.warn(os.str().c_str());
		// }
		return result;
	}

};

FASTJET_END_NAMESPACE

 