#include "DynamicalGroomer.hh"

#include <limits>

FASTJET_BEGIN_NAMESPACE      // defined in fastjet/internal/base.hh

namespace contrib 
{
  LimitedWarning DynamicalGroomer::_warnings;
  LundDeclustering DynamicalGroomer::_zero_split;

  int DynamicalGroomer::result_split_index(const std::vector<LundDeclustering>& lunds, const double& alpha)
  {
  	double min_kappa = std::numeric_limits<double>::max();
  	unsigned int min_kappa_split = 0;
  	for (unsigned int i = 0; i < lunds.size(); i++) 
  	{
  		// double kappa = 1/(z * (1-z) * pt * pow(theta,a_));
  		double kappa = 1. / ( lunds[i].z() * (1. - lunds[i].z()) * lunds[i].pair().pt() * pow(lunds[i].Delta(), alpha));
  		if (min_kappa > kappa)
  		{
  			min_kappa = kappa;
  			min_kappa_split = i;
  		}
  	}
  	if (min_kappa == std::numeric_limits<double>::max())
  	{
  		// throw Error("minimum kappa not found for a given jet - that's not correct...");
  		DynamicalGroomer::_warnings.warn("minimum kappa not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
  		return -1;
  	}
  	if (min_kappa_split > std::numeric_limits<int>::max())
  	{
		DynamicalGroomer::_warnings.warn("strange: kappa split index larger than max int?");
  	}
  	return int(min_kappa_split);
  }

  LundDeclustering& DynamicalGroomer::result_split(const std::vector<LundDeclustering>& lunds, const double& alpha)
  {
  	LundDeclustering &result = DynamicalGroomer::_zero_split;
  	double min_kappa = std::numeric_limits<double>::max();
  	for (auto const &l : lunds)
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
  		// throw Error("minimum kappa not found for a given jet - that's not correct...");
  		DynamicalGroomer::_warnings.warn("minimum kappa not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
  	}
  	return result;
  }

  LundDeclustering DynamicalGroomer::result(const PseudoJet& jet, const double& alpha)
  {
  	if (_cached_jet != &jet)
  	{
	  	_lund_splits.clear();
  		_lund_splits = _lund_gen.result(jet);
  		_cached_jet = const_cast<PseudoJet*>(&jet);
  	}
  	// int _index = result_split_index(_lund_splits, alpha);
  	// _result = &_lund_splits[_index];
  	// return *_result;
	_result = result_split(_lund_splits, alpha);
  	return _result;
  }

  /// obtain the declusterings of the primary plane of the jet
  std::vector<LundDeclustering> DynamicalGroomer::lund_splits() const
  {
  	return _lund_splits;
  }

  /// description of the class
  std::string DynamicalGroomer::description() const 
  {
	std::ostringstream oss;
	oss << "DynamicalGroomer with " << _lund_gen.description();
	return oss.str();
  }

};

FASTJET_END_NAMESPACE

 