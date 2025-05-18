const Reclamation = require('../models/reclamation');
const User = require('../models/user');

exports.createReclamation = async (req, res) => {
  try {
    const reclamation = new Reclamation(req.body);
    await reclamation.save();
    res.status(201).json(reclamation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllReclamations = async (req, res) => {
  const reclamations = await Reclamation.find();
  res.json(reclamations);
};

exports.updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, assignedTo } = req.body;

    // Vérifier si la réclamation existe
    const reclamation = await Reclamation.findById(id);
    if (!reclamation) {
      return res.status(404).json({ error: 'Réclamation non trouvée' });
    }

    // Si un utilisateur est assigné, vérifier si l'ID de l'utilisateur existe dans la base de données
    if (assignedTo) {
      const userExists = await User.findById(assignedTo);
      if (!userExists) {
        return res.status(404).json({ error: 'Utilisateur assigné non trouvé' });
      }
    }

    // Mettre à jour la réclamation avec le statut et l'utilisateur assigné
    const updatedReclamation = await Reclamation.findByIdAndUpdate(
      id,
      { status, assignedTo, updatedAt: new Date() },
      { new: true }
    );

    // Retourner la réclamation mise à jour
    res.json(updatedReclamation);
  } catch (err) {
    // Retourner une erreur avec le message
    res.status(400).json({ error: `Erreur: ${err.message}` });
  }
};

exports.updateReclamation = async (req, res) => {
  const { id } = req.params;
  const updateData = req.body;

  try {
    const updatedReclamation = await Reclamation.findByIdAndUpdate(
      id,
      { ...updateData, updatedAt: new Date() },
      { new: true }
    );

    if (!updatedReclamation) {
      return res.status(404).json({ message: 'Réclamation non trouvée' });
    }

    res.status(200).json(updatedReclamation);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour', error });
  }
};

exports.deleteReclamation = async (req, res) => {
  try {
    await Reclamation.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Réclamation supprimée' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la suppression', error });
  }
};
