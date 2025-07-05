<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'price',
        'category_id',
        'image'
    ];

    // Relationship: Each product belongs to a category
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
