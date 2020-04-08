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

  /// max pT split grooming ----
  /// obtain the splitting of max{pT's of softer prongs}
  LundDeclustering DynamicalGroomer::max_pt_softer(const PseudoJet& jet)
  {
    if (_cached_jet != &jet)
    {
      _lund_splits.clear();
      _lund_splits = _lund_gen.result(jet);
      _cached_jet = const_cast<PseudoJet*>(&jet);
    }
    _result = max_pt_softer_split(_lund_splits);
    return _result;    
  }

  /// obtain the index of the max{pT's of softer prongs} the primary plane of the jet
  int DynamicalGroomer::max_pt_softer_split_index(const std::vector<LundDeclustering>& lunds)
  {
    double max_pt_softer = std::numeric_limits<double>::min();
    unsigned int max_pt_softer_split = 0;
    for (unsigned int i = 0; i < lunds.size(); i++) 
    {
      if (lunds[i].softer().pt() > max_pt_softer)
      {
        max_pt_softer = lunds[i].softer().pt();
        max_pt_softer_split = i;
      }
    }
    if (max_pt_softer == std::numeric_limits<double>::min())
    {
      // throw Error("max pt softer not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max pt softer not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
      return -1;
    }
    if (max_pt_softer_split > std::numeric_limits<int>::max())
    {
      DynamicalGroomer::_warnings.warn("strange: max pt softer split index larger than max int?");
    }
    return int(max_pt_softer_split);    
  }

  LundDeclustering& DynamicalGroomer::max_pt_softer_split(const std::vector<LundDeclustering>& lunds)
  {
    LundDeclustering &result = DynamicalGroomer::_zero_split;
    double max_pt_softer = std::numeric_limits<double>::min();
    for (auto const &l : lunds)
    {
      if (l.softer().pt() > max_pt_softer)
      {
        max_pt_softer = l.softer().pt();
        result = l;
      }
    }
    if (max_pt_softer == std::numeric_limits<double>::min())
    {
      // throw Error("max pt softer not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max pt softer not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
    }
    return result;
  }

  ///
  /// max z split grooming ----
  /// obtain the splitting of max{z_i}
  LundDeclustering DynamicalGroomer::max_z(const PseudoJet& jet)
  {
    if (_cached_jet != &jet)
    {
      _lund_splits.clear();
      _lund_splits = _lund_gen.result(jet);
      _cached_jet = const_cast<PseudoJet*>(&jet);
    }
    _result = max_z_split(_lund_splits);
    return _result;    
  }

  /// obtain the index of the max{z_i} the primary plane of the jet
  int DynamicalGroomer::max_z_split_index(const std::vector<LundDeclustering>& lunds)
  {
    double max_z = std::numeric_limits<double>::min();
    unsigned int max_z_split = 0;
    for (unsigned int i = 0; i < lunds.size(); i++) 
    {
      if (lunds[i].z() > max_z)
      {
        max_z = lunds[i].z();
        max_z_split = i;
      }
    }
    if (max_z == std::numeric_limits<double>::min())
    {
      // throw Error("max pt softer not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max z not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
      return -1;
    }
    if (max_z_split > std::numeric_limits<int>::max())
    {
      DynamicalGroomer::_warnings.warn("strange: max z split index larger than max int?");
    }
    return int(max_z_split);    
  }

  LundDeclustering& DynamicalGroomer::max_z_split(const std::vector<LundDeclustering>& lunds)
  {
    LundDeclustering &result = DynamicalGroomer::_zero_split;
    double max_z = std::numeric_limits<double>::min();
    for (auto const &l : lunds)
    {
      if (l.z() > max_z)
      {
        max_z = l.z();
        result = l;
      }
    }
    if (max_z == std::numeric_limits<double>::min())
    {
      // throw Error("max z not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max z not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
    }
    return result;
  }

  ///
  /// max kt split grooming ----
  /// obtain the splitting of max{kt_i}
  LundDeclustering DynamicalGroomer::max_kt(const PseudoJet& jet)
  {
    if (_cached_jet != &jet)
    {
      _lund_splits.clear();
      _lund_splits = _lund_gen.result(jet);
      _cached_jet = const_cast<PseudoJet*>(&jet);
    }
    _result = max_kt_split(_lund_splits);
    return _result;    
  }

  /// obtain the index of the max{z_i} the primary plane of the jet
  int DynamicalGroomer::max_kt_split_index(const std::vector<LundDeclustering>& lunds)
  {
    double max_kt = std::numeric_limits<double>::min();
    unsigned int max_kt_split = 0;
    for (unsigned int i = 0; i < lunds.size(); i++) 
    {
      if (lunds[i].kt() > max_kt)
      {
        max_kt = lunds[i].kt();
        max_kt_split = i;
      }
    }
    if (max_kt == std::numeric_limits<double>::min())
    {
      // throw Error("max pt softer not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max kt not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
      return -1;
    }
    if (max_kt_split > std::numeric_limits<int>::max())
    {
      DynamicalGroomer::_warnings.warn("strange: max kt split index larger than max int?");
    }
    return int(max_kt_split);    
  }

  LundDeclustering& DynamicalGroomer::max_kt_split(const std::vector<LundDeclustering>& lunds)
  {
    LundDeclustering &result = DynamicalGroomer::_zero_split;
    double max_kt = std::numeric_limits<double>::min();
    for (auto const &l : lunds)
    {
      if (l.kt() > max_kt)
      {
        max_kt = l.kt();
        result = l;
      }
    }
    if (max_kt == std::numeric_limits<double>::min())
    {
      // throw Error("max kt not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max kt not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
    }
    return result;
  }

  ///
  /// max kappa split grooming ----
  /// obtain the splitting of max{kappa_i}
  LundDeclustering DynamicalGroomer::max_kappa(const PseudoJet& jet)
  {
    if (_cached_jet != &jet)
    {
      _lund_splits.clear();
      _lund_splits = _lund_gen.result(jet);
      _cached_jet = const_cast<PseudoJet*>(&jet);
    }
    _result = max_kappa_split(_lund_splits);
    return _result;    
  }

  /// obtain the index of the max{z_i} the primary plane of the jet
  int DynamicalGroomer::max_kappa_split_index(const std::vector<LundDeclustering>& lunds)
  {
    double max_kappa = std::numeric_limits<double>::min();
    unsigned int max_kappa_split = 0;
    for (unsigned int i = 0; i < lunds.size(); i++) 
    {
      if (lunds[i].kappa() > max_kappa)
      {
        max_kappa = lunds[i].kappa();
        max_kappa_split = i;
      }
    }
    if (max_kappa == std::numeric_limits<double>::min())
    {
      // throw Error("max pt softer not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max kappa not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
      return -1;
    }
    if (max_kappa_split > std::numeric_limits<int>::max())
    {
      DynamicalGroomer::_warnings.warn("strange: max kappa split index larger than max int?");
    }
    return int(max_kappa_split);    
  }

  LundDeclustering& DynamicalGroomer::max_kappa_split(const std::vector<LundDeclustering>& lunds)
  {
    LundDeclustering &result = DynamicalGroomer::_zero_split;
    double max_kappa = std::numeric_limits<double>::min();
    for (auto const &l : lunds)
    {
      if (l.kappa() > max_kappa)
      {
        max_kappa = l.kappa();
        result = l;
      }
    }
    if (max_kappa == std::numeric_limits<double>::min())
    {
      // throw Error("max kappa not found for a given jet - that's not correct...");
      DynamicalGroomer::_warnings.warn("max kappa not found for a given jet - that's not correct... - jet with no substructure? returning 'empty' split");
    }
    return result;
  }
};

FASTJET_END_NAMESPACE

 