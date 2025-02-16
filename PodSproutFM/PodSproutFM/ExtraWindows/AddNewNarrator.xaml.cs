using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;
using System.Linq;
using System.Windows;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для AddNewNarrator.xaml
    /// </summary>
    public partial class AddNewNarrator : Window
    {
        private OracleConnection con = new OracleConnection();
        private string connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";

        public event Action NarratorAdded;

        public AddNewNarrator()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            NarratorAdded += OnNarratorAdded;
        }

        private void OnNarratorAdded()
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var homePage = Application.Current.Windows.OfType<Home>().FirstOrDefault();
                homePage?.LoadNarrators();
            });
        }

        private void AddBtn_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(narratorName.Text.Trim()))
            {
                try
                {
                    con.Open();
                    using (OracleCommand cmd = con.CreateCommand())
                    {
                        cmd.CommandText = "SYS.ADDNARRATOR";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = narratorName.Text.Trim();
                        cmd.ExecuteNonQuery();
                    }
                    MessageBox.Show("Диктор добавлен успешно!");
                    NarratorAdded?.Invoke();
                    this.Close();
                    Application.Current.Windows[0].Show();
                }
                catch (OracleException ex)
                {
                    MessageBox.Show("Ошибка при добавлении диктора: " + ex.Message);
                }
                catch (Exception)
                {
                    MessageBox.Show("Диктор с таким именем уже существует!");
                }
                finally
                {
                    con.Close();
                }
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