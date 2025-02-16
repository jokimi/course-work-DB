using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для UpdateNarrator.xaml
    /// </summary>
    public partial class UpdateNarrator : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        string oldName, newName;

        public event Action NarratorUpdated;

        public UpdateNarrator()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        private void OnNarratorUpdated()
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var homePage = Application.Current.Windows.OfType<Home>().FirstOrDefault();
                homePage?.LoadNarrators();
            });
        }

        public UpdateNarrator(string old)
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            this.oldName = old;
            thisNarratorName.Text = old;
        }

        private void UpdateBtn_Click(object sender, RoutedEventArgs e)
        {
            if (!String.IsNullOrWhiteSpace(newNarratorName.Text.Trim()))
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.UPDATENARRATOR";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("POLDNARRATOR", OracleDbType.Varchar2, 30).Value = oldName;
                cmd.Parameters.Add("PNEWNARRATOR", OracleDbType.Varchar2, 30).Value = newNarratorName.Text.Trim();
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Диктор успешно обновлен!");
                    NarratorUpdated?.Invoke();
                    this.Close();
                    Application.Current.Windows[0].Show();
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Диктор с таким именем уже существует!");
                }
                con.Close();
            }
            else
            {
                MessageBox.Show("Заполните поле!");
            }
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void BtnMinimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }
    }
}