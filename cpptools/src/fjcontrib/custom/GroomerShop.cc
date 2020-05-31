#include "GroomerShop.hh"

#include <limits>
#include <vector>
#include <algorithm>
#include <cmath>

FASTJET_BEGIN_NAMESPACE      // defined in fastjet/internal/base.hh

namespace contrib 
{
	LimitedWarning GroomerShop::_warnings;
	LundDeclustering GroomerShop::_zero_split;

	// credit: https://thispointer.com/c-how-to-find-an-element-in-vector-and-get-its-index/
	// unfortunately the == operator not implemented for LundDeclustering

	bool operator==(const LundDeclustering &ld1, const LundDeclustering &ld2)
	{
		if (ld1.pair() == ld2.pair())
			return true;
		return false;
	}

	template < typename T>
	std::pair<bool, int > findInVector(const std::vector<T>  & vecOfElements, const T  & element)
	{
		std::pair<bool, int > result;
	 
		// Find given element in vector
		auto it = std::find(vecOfElements.begin(), vecOfElements.end(), element);
	 
		if (it != vecOfElements.end())
		{
			result.second = distance(vecOfElements.begin(), it);
			result.first = true;
		}
		else
		{
			result.first = false;
			result.second = -1;
		}
	 
		return result;
	}

	int GroomerShop::index(const LundDeclustering &l)
	{
		int result = -1;

		std::pair<bool, int> rpair = findInVector(_lund_splits, l);

		if (rpair.first)
			result = rpair.second;

		return result;
	}

	/// recluster and set the vector of primary lund plane splittings
	bool GroomerShop::recluster(const PseudoJet& jet)
	{
		_lund_splits.clear();
		_lund_splits = _lund_gen.result(jet);
		return (_lund_splits.size() > 0);
	}


	/// obtain the declusterings of the primary plane of the jet
	std::vector<LundDeclustering> GroomerShop::lund_splits() const
	{
		return _lund_splits;
	}

 	/// set the declusterings of the primary plane of the jet
	void GroomerShop::set_lund_splits(const std::vector<LundDeclustering>& lunds)
	{
		_lund_splits = lunds;
	}

	/// description of the class
	std::string GroomerShop::description() const 
	{
		std::ostringstream oss;
		oss << "GroomerShop with " << _lund_gen.description();
		return oss.str();
	}

	// return the split of dynamical grooming with alpha
	// https://arxiv.org/abs/1911.00375
	LundDeclustering& GroomerShop::dynamical(const double& alpha)
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double min_kappa = std::numeric_limits<double>::max();
		for (auto const &l : _lund_splits)
		{
			// double kappa = 1/(z * (1-z) * pt * pow(theta,a_));
			double kappa = 1. / ( l.z() * (1. - l.z()) * l.pair().pt() * pow(l.Delta(), alpha));
			if (min_kappa > kappa)
			{
				min_kappa = kappa;
				result = l;
			}
		}
		if (min_kappa == std::numeric_limits<double>::max())
		{
			// throw Error("minimum kappa not found for a given jet");
			GroomerShop::_warnings.warn("minimum kappa not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max pT split grooming ----
	/// obtain the splitting of max{pT's of softer prongs}
	LundDeclustering& GroomerShop::max_pt_softer()
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double max_pt_softer = std::numeric_limits<double>::min();
		for (auto const &l : _lund_splits)
		{
			if (l.softer().pt() > max_pt_softer)
			{
				max_pt_softer = l.softer().pt();
				result = l;
			}
		}
		if (max_pt_softer == std::numeric_limits<double>::min())
		{
			// throw Error("max pt softer not found for a given jet");
			GroomerShop::_warnings.warn("max pt softer not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max z split grooming ----
	/// obtain the splitting of max{z_i}
	LundDeclustering& GroomerShop::max_z()
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double max_z = std::numeric_limits<double>::min();
		for (auto const &l : _lund_splits)
		{
			if (l.z() > max_z)
			{
				max_z = l.z();
				result = l;
			}
		}
		if (max_z == std::numeric_limits<double>::min())
		{
			// throw Error("max z not found for a given jet");
			GroomerShop::_warnings.warn("max z not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max kt split grooming ----
	/// obtain the splitting of max{kt_i}
	LundDeclustering& GroomerShop::max_kt()
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double max_kt = std::numeric_limits<double>::min();
		for (auto const &l : _lund_splits)
		{
			if (l.kt() > max_kt)
			{
				max_kt = l.kt();
				result = l;
			}
		}
		if (max_kt == std::numeric_limits<double>::min())
		{
			// throw Error("max kt not found for a given jet");
			GroomerShop::_warnings.warn("max kt not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max kappa split grooming ----
	/// obtain the splitting of max{kappa_i}
	LundDeclustering& GroomerShop::max_kappa()
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double max_kappa = std::numeric_limits<double>::min();
		for (auto const &l : _lund_splits)
		{
			if (l.kappa() > max_kappa)
			{
				max_kappa = l.kappa();
				result = l;
			}
		}
		if (max_kappa == std::numeric_limits<double>::min())
		{
			// throw Error("max kappa not found for a given jet");
			GroomerShop::_warnings.warn("max kappa not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// max tf split grooming ----
	/// obtain the splitting of max{tf_i}
	LundDeclustering& GroomerShop::max_tf()
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double max_tf = std::numeric_limits<double>::min();
		for (auto const &l : _lund_splits)
		{
			double _tf = l.z() * l.Delta() * l.Delta();
			if (_tf > max_tf)
			{
				max_tf = _tf;
				result = l;
			}
		}
		if (max_tf == std::numeric_limits<double>::min())
		{
			// throw Error("max tf not found for a given jet");
			GroomerShop::_warnings.warn("max tf not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	/// min tf split grooming ----
	/// obtain the splitting of min{tf_i}
	LundDeclustering& GroomerShop::min_tf()
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		double min_tf = std::numeric_limits<double>::max();
		for (auto const &l : _lund_splits)
		{
			double _tf = l.z() * l.Delta() * l.Delta();
			if (_tf < min_tf)
			{
				min_tf = _tf;
				result = l;
			}
		}
		if (min_tf == std::numeric_limits<double>::max())
		{
			// throw Error("min tf not found for a given jet");
			GroomerShop::_warnings.warn("min tf not found for a given jet - jet with no substructure? returning and 'empty' split");
		}
		return result;
	}

	// soft drop
	LundDeclustering& GroomerShop::soft_drop(double beta, double zcut, double R0)
	{
		LundDeclustering &result = GroomerShop::_zero_split;
		for (auto const &l : _lund_splits)
		{
			if (l.z() > zcut * pow(l.Delta() / R0, beta))
			{
				result = l;
				break;
			}
		}
		return result;
	}

};

FASTJET_END_NAMESPACE

 